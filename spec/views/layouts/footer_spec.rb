# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_footer' do
  before { render }

  # From the UMass Digital Brand Guide - "We live in a digital world."
  it 'has a span with a class of content' do
    expect(rendered).to have_tag('span.content')
  end

  it 'includes the copyright year' do
    expect(rendered).to include(Time.zone.now.year.to_s)
  end

  it 'includes a link to umass.edu' do
    expect(rendered).to have_tag('a', with: { href: 'http://umass.edu' })
  end

  it 'links to the correct Site Policies URL' do
    expect(rendered).to have_tag 'a', with: { href: 'http://umass.edu/site_policies' } do
      with_text 'Site Policies'
    end
  end

  it 'has the Site Contact Email' do
    expect(rendered).to have_tag 'a', with: { href: 'mailto:transit-it@admin.umass.edu' } do
      with_text 'Site Contact'
    end
  end
end
