class DogsController < ApplicationController

  before_action :authenticate_user!, only: [:new, :edit, :create, :destroy]
  before_action :set_dog, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:create]

  # GET /dogs
  # GET /dogs.json
  def index
    @dogs = Dog.all.paginate(page: params[:page])
    # @dogs = Dog.owned_by_or_free(current_user).paginate(page: params[:page])
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
        @dog.images.attach(params[:dog][:images]) if params[:dog][:images].present?

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
        @dog.images.attach(params[:dog][:images]) if params[:dog][:images].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully updated.' }
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
      format.html { redirect_to dogs_url, notice: 'Dog was successfully destroyed.' }
      format.json { head :no_content }
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
