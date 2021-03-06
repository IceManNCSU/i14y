namespace :fake do
  desc "Creates a specified number of test documents for an existing collection"
  # Sample usage, to create 10 documents for the collection with handle 'my_drawer':
  # rake fake:documents[my_drawer,10]

  task :documents, [:index_name, :document_count] => [:environment] do |t, args|
    Document.index_name = Document.index_namespace(args[:index_name])
    count = args[:document_count].to_i

    count.times { Document.create(fake_doc) }
  end

  private

  def fake_doc
    { _id: Time.now.to_f.to_s,
      title: Faker::Lorem.words(3).join(' '),
      path: Faker::Internet.url,
      created: Faker::Time.between(3.years.ago, Date.today).to_json,
      description:  Faker::Lorem.sentence,
      content: Faker::Lorem.paragraphs.join("\n"),
      promote: [true,false].sample,
      language: ['en','es','fr'].sample,
      tags: %w(foo bar baz).sample([1,2,3].sample).join(',')
    }
  end
end
