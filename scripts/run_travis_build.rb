require 'travis'
require 'net/http'
require 'uri'


build_overrides = { 
  "request" => {
    "branch" => 'master',
    "config" => {
      "merge_mode"=> "merge",
      "env"=> {
        "CUSTOM_VAR"=> "yes"
      }
    }
  }
}

$client = Travis::Client.new(access_token: ENV['TRAVIS_TOKEN'])
$client.clear_cache




def send_http_request_for_new_build(build_overrides, repo_object)
  uri = URI.parse(repo_object["endpoint"])
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Accept"] = "application/json"
  request["Travis-Api-Version"] = "3"
  request["Authorization"] = "token #{ENV['TRAVIS_TOKEN']}"
  request.body = build_overrides.to_json

  req_options = {
   use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
   http.request(request)
  end
  
  return response
end



def wait_for_next_build(repo,build_number)
  loop do 
    $client.clear_cache
    build = repo.build(build_number)
    p "Build number: #{build_number} is unavailable"
    break if !build.nil?;
    sleep(2)
  end  
end

def find_failed_job_and_log(build)
  build.jobs.each do |job|
      if !job.passed?
        File.open("fail.log", "a") {|f| f.write(job.log.clean_body) }
      end   
  end
end  

def retrieve_repos(repos)
  output_repos_array_of_objects = []
  repos.each { |repo_name|  
      temp = {}
      temp["repo"] = $client.repo(repo_name)
      temp["current_build_number"] = $client.repo(repo_name).branch('master').number.to_i
      temp["next_build_number"] = temp["current_build_number"] + 1
      temp["endpoint"] = "https://api.travis-ci.org/repo/#{CGI.escape(repo_name)}/requests"
      output_repos_array_of_objects.push(temp)
  }
  return output_repos_array_of_objects
end


def run_build_process(repo_object, build_overrides)
  
  
  repo = repo_object["repo"]
  
  response = send_http_request_for_new_build(build_overrides, repo_object)
  if ["200", "202"].include? response.code
    p JSON.parse(response.body)
    wait_for_next_build(repo, repo_object["next_build_number"])
    build = repo.build(repo_object["next_build_number"])
    loop do 
      $client.clear_cache
      build = repo.build(repo_object["next_build_number"])
      p "build number: #{build.number}, build state: #{build.state}"
      break if build.finished?;
      sleep(2)
    end  
    
    
    if !build.passed?
      find_failed_job_and_log(build)
    end
  else
    p "response code is: #{response.code}"
    p response.body
    exit 2
  end
end




repos = retrieve_repos(['cloudinary-misha/node-tests-lab'])
repos.each { |repo_object|  
  run_build_process(repo_object, build_overrides)
}




