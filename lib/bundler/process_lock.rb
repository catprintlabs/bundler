# frozen_string_literal: true

module Bundler
  class ProcessLock
    def self.lock(bundle_path = Bundler.bundle_path)
      lock_file_path = File.join(bundle_path, "bundler.lock")
      has_lock = false
      puts "lock file path #{lock_file_path}"
      puts "from process #{Thread.current.object_id}"
      File.open(lock_file_path, "w") do |f|
        puts 'locking this file'
        if f.flock(File::LOCK_NB)
          puts 'file is locked we will spin here'
        end
        f.flock(File::LOCK_EX)
        has_lock = true
        puts 'yielding from inside open lockfile'
        yield
        f.flock(File::LOCK_UN)
      end
    rescue Errno::EACCES, Errno::ENOLCK
      puts 'in rescue clause'
      # In the case the user does not have access to
      # create the lock file or is using NFS where
      # locks are not available we skip locking.
      yield
    ensure
      FileUtils.rm_f(lock_file_path) if has_lock
      puts 'end of lock'
    end
  end
end
