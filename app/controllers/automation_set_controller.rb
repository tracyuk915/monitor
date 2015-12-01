require './lib/jenkins_client'

class AutomationSetController < ApplicationController

  def show
    @automation_set = AutomationSet.find(params[:id])
  end

  def index
    @current_user = session[:current_user]
  end

  def list
    sets = []
    AutomationSet.all.each do |automation_set|
      single_set = {id: automation_set.id, name: automation_set.name, jobs: []}
      automation_set.automation_jobs.each do |automation_job|
        single_set[:jobs] << {job_id: automation_job.id, job_url: automation_job.url, job_name: automation_job.name}
      end
      sets << single_set
    end
    render json: sets
  end

  def new
    client = JenkinsClient.new
    
    automation_set = AutomationSet.find(1)
    jobs = automation_set.automation_jobs

    jobs.each do |job|
      p "job names: #{job.name}"
      result = client.kick_build("Staging-Engage-SW-Full-Tracy")
      p "hudson result is: #{result}"
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit

  end

  def kickoff

    # set_id = ddd
    # jobs = AutomationSet.find(set_id)

    # JenkinsClient.

    client = JenkinsClient.new
    client.kick_build

    respond_to do |format|
    format.json
  end

  end

end
