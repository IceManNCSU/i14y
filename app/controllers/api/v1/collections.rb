module API
  module V1
    class Collections < Grape::API
      prefix 'api'
      version 'v1'
      default_format :json
      format :json
      rescue_from Grape::Exceptions::ValidationErrors do |e|
        rack_response({ developer_message: e.message, status: 400 }.to_json, 400)
      end

      http_basic do |admin_user, admin_password|
        error_hash = { developer_message: "Unauthorized", status: 400 }
        error!(error_hash, 400) unless auth?(admin_user, admin_password)
        true
      end

      helpers do
        def ok(user_message)
          { status: 200, developer_message: "OK", user_message: user_message }
        end

        def auth?(admin_user, admin_password)
          yaml = YAML.load_file("#{Rails.root}/config/secrets.yml")
          env_secrets = yaml[Rails.env]
          admin_user == env_secrets['admin_user'] && admin_password == env_secrets['admin_password']
        end

      end

      resource :collections do
        desc "Create a collection"
        params do
          requires :handle,
                   allow_blank: false,
                   type: String,
                   regexp: %r(^[a-z0-9._]+$),
                   desc: "Immutable name of the logical index used when authenticating Document API calls"
          requires :token,
                   type: String,
                   allow_blank: false,
                   desc: "Token to be used when authenticating Document API calls"
        end
        post do
          handle = params[:handle]
          collection = Collection.create(_id: handle, token: params[:token])
          error!(collection.errors.messages, 400) unless collection.valid?
          es_documents_index_name = [Document.index_namespace(handle), 'v1'].join('-')
          Document.create_index!(index: es_documents_index_name)
          Elasticsearch::Persistence.client.indices.put_alias index: es_documents_index_name,
                                                              name: Document.index_namespace(handle)
          ok("Your collection was successfully created.")
        end

        desc "Delete a collection"
        delete ':handle' do
          handle = params.delete(:handle)
          collection = Collection.find(handle)
          error!(collection.errors.messages, 400) unless collection.destroy
          Elasticsearch::Persistence.client.indices.delete(index: [Document.index_namespace(handle), '*'].join('-'))
          ok("Your collection was successfully deleted.")
        end
      end
    end
  end
end