require 'rails_helper'

describe 'Dog resource', type: :feature do
  # before do
  #   visit "/users/sign_in"
  #   fill_in "user[email]", with: 'reymillenium@gmail.com'
  #   fill_in "user[password]", with: '1234567'
  #   click_button "Login"
  #   # user = FactoryBot.create(:user)
  #   # login_as(user, :scope => :user)
  # end



  # it 'can create a profile' do
  #   visit new_dog_path
  #   # elementName = page.find("name")
  #   # element.set(@visitor[:name])
  #   # elementName.set('Speck')
  #   # elementDescription = page.find("description")
  #   # elementDescription.set('Just a dog')
  #
  #
  #   # find('#dog_name', visible: true).set 'Speck'
  #   # find('#dog_description', visible: true).set 'Just a dog'
  #   fill_in 'Name', with: 'Speck', visible: false
  #   fill_in 'Description', with: 'Just a dog', visible: false
  #   attach_file 'Image', 'spec/fixtures/images/speck.jpg'
  #   click_button 'Create Dog'
  #   expect(Dog.count).to eq(1)
  # end

  it 'can edit a dog profile' do
    dog = create(:dog)
    visit edit_dog_path(dog)
    fill_in 'Name', with: 'Speck'
    click_button 'Update Dog'
    expect(dog.reload.name).to eq('Speck')
  end

  it 'can delete a dog profile' do
    dog = create(:dog)
    visit dog_path(dog)
    # click_link "Delete #{dog.name}'s Profile"
    click_link "Delete"
    expect(Dog.count).to eq(0)
  end
end
