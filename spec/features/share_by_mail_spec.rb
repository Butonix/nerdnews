# encoding: utf-8

require 'spec_helper'

describe 'Share By Mail', js: true do
  before do
    @story  = FactoryGirl.create :approved_story
    @user   = FactoryGirl.create :user
  end

  it "sends email to share story via unknown user"  do
    visit story_path(@story)
    within 'article ul.social-icons' do
      find(:xpath, "//a[@data-target='#mailModal']").click
    end
    fill_in 'share_by_mail_name', with: 'arash'
    fill_in 'share_by_mail_reciever', with: 'arash@example.com'
    fill_in 'share_by_mail_spam_answer', with: 'four'
    click_button 'ارسال'
    page.should have_content 'موفقیت'
    last_email.to.should include('arash@example.com')
  end

  it "sends email to share story via known user" do
    login @user
    visit story_path(@story)
    within 'article ul.social-icons' do
      find(:xpath, "//a[@data-target='#mailModal']").click
    end
    fill_in 'share_by_mail_name', with: 'arash'
    fill_in 'share_by_mail_reciever', with: 'arash@example.com'
    click_button 'ارسال'
    page.should have_content 'موفقیت'
    last_email.to.should include('arash@example.com')
  end
end
