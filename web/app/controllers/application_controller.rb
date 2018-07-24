class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  private
  def structure_files sources, dir_path
    sources.each do |key, value|
      if value.key?(:"/content")
        file = key
        File.open "#{dir_path}/#{file}", "w" do |f|
          f.write value[:"/content"]
        end
      else
        dir = key
        new_dir_path = "#{dir_path}/#{dir}"
        FileUtils::mkdir_p new_dir_path
        structure_files value, new_dir_path
      end
    end
  end

  def oyente_cmd filepath, options
    return `python /oyente/oyente/oyente.py -s #{filepath} -w#{options}`
  end

  def bytecode_exists?
    return !oyente_params[:bytecode].nil?
  end

  def oyente_params
    params.require(:data).permit(:current_file, :sources, :timeout, :global_timeout, :depthlimit, :gaslimit, :looplimit, :email, :bytecode)
  end

  def check_params
    oyente_params.each do |opt, val|
      unless ["sources", "current_file", "email", "bytecode"].include?(opt)
        return false unless is_number?(val)
      end
    end
    return true
  end

  def options
    opts = ""
    oyente_params.each do |opt, val|
      unless ["sources", "current_file", "email", "bytecode"].include?(opt)
        opt = opt.gsub(/_/, '-')
        opts += " --#{opt} #{val}"
      end
    end
    return opts
  end

  def is_number? string
    true if Integer(string) && Integer(string) > 0 rescue false
  end
end
