class DogsController < ApplicationController
  # before_action :authenticate_user!, only: [:new, :edit, :create, :destroy]
  before_action :set_dog, only: [:show, :edit, :update, :destroy, :like]
  before_action :set_user, only: [:create, :like]

  # GET /dogs
  # GET /dogs.json
  def index
    @dogs = Dog.ordered_by_likes.paginate(page: params[:page])
  end

  # GET /dogs/1
  # GET /dogs/1.json
  def show
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
  end

  # POST /dogs
  # POST /dogs.json
  def create
    @dog = Dog.new(dog_params)
    @dog.user_id = @user.id

    respond_to do |format|
      if @dog.save
        # @dog.images.attach(params[:dog][:images]) if params[:dog][:images].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully created.' }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1
  # PATCH/PUT /dogs/1.json
  def update

    # binding.pry
    respond_to do |format|
      if @dog.update(dog_params)
        # @dog.images.attach(params[:dog][:images]) if params[:dog][:images].present?

        format.html { redirect_to @dog, notice: t('dogs.update.success_notice') }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.json
  def destroy
    @dog.destroy
    respond_to do |format|
      format.html { redirect_to dogs_url, notice: t('dogs.destroy.success_notice') }
      format.json { head :no_content }
    end
  end

  def like
    if @dog.likeable_by?(@user)
      @like = Like.new
      @like.dog_id = @dog.id
      @like.user_id = @user.id
      @like.save
    elsif @dog.unlikeable_by?(@user)
      @like = Like.by_user(@user).by_dog(@dog).first
      @like.destroy
    else
      flash[:error] = t('errors.resources.invalid_operation')
    end
    respond_to do |format|
      format.html { redirect_to @dog }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dog
    @dog = Dog.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dog_params
    params.require(:dog).permit(:name, :description, images: [])
  end
end
