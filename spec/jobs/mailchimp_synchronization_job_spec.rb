# encoding: utf-8

#  Copyright (c) 2018, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe MailchimpSynchronizationJob do

  let(:group) { groups(:top_group) }
  let(:mailing_list) { Fabricate(:mailing_list, group: group, mailchimp_api_key: '1234') }

  subject { MailchimpSynchronizationJob.new(mailing_list.id) }

  it 'it sets syncing to false after success' do
    time_now = Time.zone.now
    allow_any_instance_of(ActiveSupport::TimeZone).to receive(:now).and_return(time_now)
    allow_any_instance_of(Synchronize::Mailchimp::Client).to receive(:members).and_return([])

    subject.enqueue!

    Delayed::Worker.new.work_off
    mailing_list.reload

    expect(mailing_list.mailchimp_syncing).to be false
    expect(mailing_list.mailchimp_last_synced_at.to_i).to eq(time_now.to_i)
  end

  it 'it sets syncing to false after success' do
    time_now = Time.zone.now
    allow_any_instance_of(ActiveSupport::TimeZone).to receive(:now).and_return(time_now)
    expect_any_instance_of(MailchimpSynchronizationJob).to receive(:perform).and_throw(Exception)

    subject.enqueue!

    Delayed::Worker.new.work_off
    mailing_list.reload

    expect(mailing_list.mailchimp_syncing).to be false
    expect(mailing_list.mailchimp_last_synced_at).to be_nil
  end

end
