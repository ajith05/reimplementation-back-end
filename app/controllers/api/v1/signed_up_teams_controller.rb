class Api::V1::SignedUpTeamsController < ApplicationController

  # Returns signed up topics using project_topic assignment id
  # Retrieves project_topic using topic_id as a parameter
  def index
    @project_topic = ProjectTopic.find(params[:topic_id])
    @signed_up_team = SignedUpTeam.find_team_participants(@project_topic.assignment_id)
    render json: @signed_up_team
  end

  # Implemented by signed_up_team.rb (Model) --> signup_team_for_topic
  def create; end

  # Update signed_up_team using parameters.
  def update
    @signed_up_team = SignedUpTeam.find(params[:id])
    if @signed_up_team.update(signed_up_teams_params)
      render json: { message: "The team has been updated successfully. " }, status: 200
    else
      render json: @signed_up_team.errors, status: :unprocessable_entity
    end
  end

  # Sign up using parameters: team_id and topic_id
  # Calls model method signup_team_for_topic
  def signup
    team_id = params[:team_id]
    topic_id = params[:topic_id]
    @signed_up_team = SignedUpTeam.signup_team_for_topic(topic_id, team_id)
    @signed_up_team.save
    if @signed_up_team
      render json: { message: "Signed up team successful!" }, status: :created
    else
      render json: { message: @signed_up_team.errors }, status: :unprocessable_entity
    end
  end

  # Method for signing up as student
  # Params : topic_id
  # Get team_id using model method get_team_id_for_user
  # Call signup_team_for_topic Model method
  def signup_user
    user_id = params[:user_id]
    topic_id = params[:topic_id]
    assignment_id = params[:assignment_id]
    team_id = SignedUpTeam.get_team_id_for_user(user_id, assignment_id)
    @signed_up_team = SignedUpTeam.signup_team_for_topic(topic_id, team_id)
    if @signed_up_team
      render json: { message: "Signed up team successful!" }, status: :created
    else
      render json: { message: @signed_up_team.errors }, status: :unprocessable_entity
    end
  end

  # Delete signed_up team. Calls method delete_signed_up_team from the model.
  def destroy
    @signed_up_team = SignedUpTeam.find(params[:id])
    if SignedUpTeam.delete_signed_up_team(@signed_up_team.team_id)
      render json: { message: 'Signed up teams was deleted successfully!' }, status: :ok
    else
      render json: @signed_up_team.errors, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters method for permitting attributes related to signed-up teams.
  # Ensures only the allowed parameters are passed for creating or updating a signed-up team.
  def signed_up_teams_params
    params.require(:signed_up_team).permit(:topic_id, :team_id, :is_waitlisted, :preference_priority_number)
  end

end
