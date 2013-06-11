class Roster::ImportMailer < ActionMailer::Base
  def receive(message)
    components = message.subject.split(/-/)

    # Hopefully get the message type in here somehow
    chapter_code = components[0]
    chapter = Roster::Chapter.where(code: chapter_code).first!

    importer = Roster::VcImporter.new

    message.attachments.each do |att|
      StringIO.open(att.body.decoded) do |io|
        importer.import_data(chapter, io)
      end
    end
  end
end
