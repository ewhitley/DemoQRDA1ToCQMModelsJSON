#run "bundle install" to install everything - then you can run this
#you'll need to run "bundle install" as an administrator

#standard Ruby stuff
require 'json'

#=====================================
#The following are all pulled in from the Gemfile and installed when you do "bundle install"
#XML library
require 'nokogiri'

#libraries from the ONC/CMS Project Tacoma repository
require 'cqm-reports'
require 'cqm/models'
#=====================================


#OK, so let's pare some QRDA I
#let's give the system a directory we want to go through
sourceDirPath = "C:/Users/ewwhi/OneDrive - Eric Whitley/Health Catalyst/Projects/QRDA1/RubyParser/qrda1_samples"
targetDirPath = "C:/Users/ewwhi/OneDrive - Eric Whitley/Health Catalyst/Projects/QRDA1/RubyParser/json_exports"

if File.directory?(sourceDirPath) then
    puts "Reading source files from: '" + sourceDirPath + "'"    
else
    raise "ERROR! Directory '" + sourceDirPath + "' DOES NOT EXIST"   
end

FileUtils.mkdir_p(targetDirPath) unless File.exists?(targetDirPath)
puts "Saving JSON files to: '" + targetDirPath + "'"

puts ""

Dir.foreach(sourceDirPath) do |filename|
    next if filename == '.' or filename == '..'
    # Do work on the remaining files & directories
    #puts filename
    filePath = File.join(sourceDirPath, filename)
    fileBaseName = File.basename(filename,File.extname(filename))

    puts "Reading " + filePath
    #puts fileBaseName
    jsonFilePath = File.join(targetDirPath, fileBaseName + ".json")

    #attempt to open the source file
    file = File.open(filePath)

    #do the basic XML parsing
    doc = Nokogiri::XML(file)
    #we need to add some namespaces because they're not specified properly
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    #parse the QRDA I
    patient, warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

    #convert the Ruby hash to JSON
    j = patient.to_json

    # #write to screen
    # puts j

    #save our file
    File.write(jsonFilePath, j)
    puts "Saved file to :'" + jsonFilePath + "'"

end


