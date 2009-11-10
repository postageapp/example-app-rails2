namespace :postage do
  namespace :requests do
    
    desc 'List currently stored requests'
    task :list => :environment do
      list_of_files.each do |file|
        puts file
      end
    end
    
    desc 'Remove all stored requests'
    task :purge => :environment do
      list_of_files.each do |file|
        puts "Removing #{file}"
        FileUtils.rm File.join(file_path, file)
      end
    end
    
    desc 'Attempt to resend stored requests'
    task :send => :environment do
      list_of_files.each do |file|
        puts ">>> Loading #{file} ..."
        request = YAML::load_file(File.join(file_path, file))
        puts "Attempting to resend by calling #{request[:url]} with given data:"
        puts request[:arguments].inspect
        puts
        
        # if request was a success, remove file
        if Postage::Request.new.call!(request[:url], request[:arguments])
          puts 'Send was successful. Removing stored file.'
          FileUtils.rm File.join(file_path, file)
        else
          puts 'Failed to resend'
        end
      end
    end
    
  end
end

def list_of_files
  Dir.entries(file_path).select{|f| f.match /\.yaml$/}
end

def file_path
  @file_path ||= Postage.stored_failed_requests_path
end