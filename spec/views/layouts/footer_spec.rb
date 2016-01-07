require 'rails_helper'
include RSpecHtmlMatchers

describe 'layouts/_footer.haml' do
  # From the UMass Digital Brand Guide - "We live in a digital world."
  it 'has a span with a class of content' do
    render
    expect(rendered).to have_tag 'span.content'
  end
  it 'includes the copyright year' do
    render
    expect(rendered).to include Time.zone.now.year.to_s
  end
  it 'includes a link to umass.edu' do
    render
    expect(rendered).to have_tag 'a', with: { href: 'http://umass.edu' }
  end
  it 'links to the correct Site Policies URL' do
    render
    expect(rendered)
      .to have_tag 'a', with: { href: 'http://umass.edu/site_policies' } do
      with_text 'Site Policies'
    end
  end
  it 'has the configured value as the Site Contact Email' do
    site_contact_email = 'your-it-department@test.host'
    allow_any_instance_of(ApplicationConfiguration).to receive :configured_value
    expect_any_instance_of(ApplicationConfiguration)
      .to receive(:configured_value)
      .with([:email, :site_contact_email])
      .and_return site_contact_email
    render
    expect(rendered)
      .to have_tag 'a', with: { href: "mailto:#{site_contact_email}" } do
      with_text 'Site Contact'
    end
  end
end
