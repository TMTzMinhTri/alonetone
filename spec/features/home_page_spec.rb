require "rails_helper"

RSpec.describe 'home page', type: :feature, js: true do
  it 'renders' do
    visit '/'
    expect(page).to have_selector('#home_latest_area', visible: true)
    expect(page).not_to have_selector('.profile_link')

    track_chunk = find(".asset", match: :first)
    track_chunk.find(".play_link").click

    page.scroll_to(track_chunk)
    expect(track_chunk).to have_selector('.private_check_box label', visible: true)
    expect(track_chunk).to have_no_selector('.add_to_favorites')

    fast_forward_animations
    Percy.snapshot(page, name: 'Home as Guest before private check box click')
    track_chunk.find('.private_check_box label').click

    expect(track_chunk).to have_selector('span.only_user_name', visible: true)

    track_chunk.find('textarea').fill_in with: "Hey this is a comment from a guest"

    # private checkbox is technically offscreen, but we still want to confirm it's checked
    expect(track_chunk.find('.private_check_box .private', visible: :all)).to be_checked
    Percy.snapshot(page, name: 'Home as Guest')

    akismet_stub_response_ham
    track_chunk.find('input[type=submit]').click
    expect(track_chunk.find('.ajax_waiting')).to have_text('Submitted, thanks!')
  end

  it 'renders logged in' do
    logged_in(:arthur) do
      visit '/'
      expect(page).to have_selector('.profile_link')
      # let's snap the dark theem nav while we are at it
      switch_themes
      expect(page).to have_selector('.profile_link')

      track = find(".asset", match: :first)
      track.find(".play_link").click

      page.scroll_to(track)
      expect(track).to have_selector('.add_to_favorites')
      expect(track).to have_selector('.stitches_seek')

      # This currently fails, because playback actually fails
      # TODO: look into the fixtures and confirm playback on this particular track is happy
      # expect(track).to have_selector('.stitches_seek .loaded')
      track.find(".stitches_seek").click # click in the middle of the seekbar
      track.find(".play_link").click # pause the track
      expect(track).to have_selector('.add_to_favorites')
      Percy.snapshot(page, name: 'Home as User')
    end
  end
end
