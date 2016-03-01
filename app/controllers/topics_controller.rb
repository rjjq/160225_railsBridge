class TopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic, only: [:show, :edit, :update, :destroy, :upvote, :downvote]

  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to topics_path, notice: 'Topic was successfully created.' }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { render :new }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to topics_path, notice: 'Topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic }
      else
        format.html { render :edit }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to topics_url, notice: 'Topic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upvote
    # current_vote_type = get_vote_type
    # if current_vote_type.nil?
    #   new_vote = @topic.votes.create
    #   new_vote.user_id = current_user.id
    #   new_vote.vote_type = "up"
    #   new_vote.save

    #   updated_votes_count = @topic.votes_count + 1
    #   @topic.update(votes_count: updated_votes_count)
    # elsif current_vote_type == "up"
    #   flash[:notice] = "每人只能投+1投票一次"
    # elsif current_vote_type == "down"
    #   @topic.votes.find_by(user_id: current_user.id).update(vote_type: "zero")

    #   updated_votes_count = @topic.votes_count + 1
    #   @topic.update(votes_count: updated_votes_count)
    # end

    if has_vote
      if has_upvote
        flash[:notice] = "每人只能投+1投票一次"
      elsif has_devote
        @topic.votes.find_by(user_id: current_user.id).update(vote_type: "zero")

        updated_votes_count = @topic.votes_count + 1
        @topic.update(votes_count: updated_votes_count)
      else
        @topic.votes.find_by(user_id: current_user.id).update(vote_type: "up")

        updated_votes_count = @topic.votes_count + 1
        @topic.update(votes_count: updated_votes_count)
      end
    else
      new_vote = @topic.votes.create
      new_vote.user_id = current_user.id
      new_vote.vote_type = "up"
      new_vote.save

      updated_votes_count = @topic.votes_count + 1
      @topic.update(votes_count: updated_votes_count)
    end

    redirect_to topics_path
  end

  def downvote
    if has_vote
      if has_devote
        flash[:notice] = "每人只能投-1投票一次"
      elsif has_upvote
        @topic.votes.find_by(user_id: current_user.id).update(vote_type: "zero")

        updated_votes_count = @topic.votes_count - 1
        @topic.update(votes_count: updated_votes_count)
      else
        @topic.votes.find_by(user_id: current_user.id).update(vote_type: "down")

        updated_votes_count = @topic.votes_count - 1
        @topic.update(votes_count: updated_votes_count)
      end
    else
      new_vote = @topic.votes.create
      new_vote.user_id = current_user.id
      new_vote.vote_type = "down"
      new_vote.save

      updated_votes_count = @topic.votes_count - 1
      @topic.update(votes_count: updated_votes_count)
    end

    redirect_to topics_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = Topic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_params
      params.require(:topic).permit(:title, :description)
    end

    def has_vote
      if @topic.votes.where(user_id: current_user.id).count > 0
        return true
      else
        return false
      end
    end

    def has_upvote
      if !@topic.votes.find_by(user_id: current_user.id, vote_type: "up").nil?
        return true
      else
        return false
      end
    end

    def has_devote
      if !@topic.votes.find_by(user_id: current_user.id, vote_type: "down").nil?
        return true
      else
        return false
      end
    end
end
