require 'octokit'

SCHEDULER.every '1m', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => "xxx")
  my_organization = "xxxx"
  interesting_repos = ["mt", "fe", "local-dev-environment", "docker"]
  repos = client.organization_repositories(my_organization).map { |repo| repo.name } .select{|j| interesting_repos.any?{|k|j.start_with?(k)}}

  open_pull_requests = repos.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'open').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
        creator: "@" + pull.user.login,
        })
    end
    pulls
  }

  send_event('prs', { header: "Open Pull Requests", pulls: open_pull_requests })
end
