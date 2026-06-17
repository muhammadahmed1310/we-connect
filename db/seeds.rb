# frozen_string_literal: true

# Overall roles in the system (users can have multiple roles)
#admin_role = Role.create!(name: 'admin')
#staff_role = Role.create!(name: 'staff')
#subscriber_role = Role.create!(name: 'subscriber')
#explorer_role = Role.create!(name: 'explorer')
#Role.create!(name: 'user')

# Roles for a user


choice = Choice.create!(name: 'user_role_type')
choice.choice_items.create!(name: 'administrator')
choice.choice_items.create!(name: 'staff')
choice.choice_items.create!(name: 'subscriber')
choice.choice_items.create!(name: 'explorer')
choice.choice_items.create!(name: 'sologoer')
choice.choice_items.create!(name: 'fellow')
choice.choice_items.create!(name: 'expedition leader')
choice.choice_items.create!(name: 'community manager')
choice.choice_items.create!(name: 'first expedition')
choice.choice_items.create!(name: 'guide')
choice.choice_items.create!(name: 'steering group')
choice.choice_items.create!(name: 'podcast guest')
choice.choice_items.create!(name: 'partner')
choice.choice_items.create!(name: 'group manager')
choice.choice_items.create!(name: 'drop-out')

# Roles for a user in a expedition
choice = Choice.create!(name: 'expedition_role_type')
choice.choice_items.create!(name: 'leader')
choice.choice_items.create!(name: 'manager')
choice.choice_items.create!(name: 'guide')
choice.choice_items.create!(name: 'explorer')
choice.choice_items.create!(name: 'fellow')
choice.choice_items.create!(name: 'drop-out')

# Roles for a organisation in a expedition
choice = Choice.create!(name: 'expedition_organisation_type')
choice.choice_items.create!(name: 'funder')
choice.choice_items.create!(name: 'partner')
choice.choice_items.create!(name: 'location_provider')

# Roles for a user in a organisation
choice = Choice.create!(name: 'organisation_user_role_type')
choice.choice_items.create!(name: 'primary_contact')
choice.choice_items.create!(name: 'administrator')
choice.choice_items.create!(name: 'member')

choice = Choice.create!(name: 'expedition_type')
choice.choice_items.create!(name: 'Group')
choice.choice_items.create!(name: 'Solo')
choice.choice_items.create!(name: 'Themed')
choice.choice_items.create!(name: 'DIY')

choice = Choice.create!(name: 'expedition_phase_type_solo')
choice.choice_items.create!(name: 'Active')

choice = Choice.create!(name: 'expedition_phase_type_group')
choice.choice_items.create!(name: 'Kick-off')
choice.choice_items.create!(name: 'Recruitment')
choice.choice_items.create!(name: 'Preparation')
choice.choice_items.create!(name: 'Delivery')
choice.choice_items.create!(name: 'Dissemination')

choice = Choice.create!(name: 'organisation_type')
choice.choice_items.create!(name: 'Corporate')
choice.choice_items.create!(name: 'Community')
choice.choice_items.create!(name: 'Funding')

choice = Choice.create!(name: 'location_type')
choice.choice_items.create!(name: 'Expedition Venue')
choice.choice_items.create!(name: 'Individual Location')
choice.choice_items.create!(name: 'Corporate Location')

choice = Choice.create!(name: 'organisation_location_type')
choice.choice_items.create!(name: 'Primary')
choice.choice_items.create!(name: 'Temporary')

choice = Choice.create!(name: 'activity_location_type')
choice.choice_items.create!(name: 'Primary')
choice.choice_items.create!(name: 'Meeting')

choice = Choice.create!(name: 'content_type')
choice.choice_items.create!(name: 'Email')
choice.choice_items.create!(name: 'Blog')
choice.choice_items.create!(name: 'Podcast')

choice = Choice.create!(name: 'activity_type')
choice.choice_items.create!(name: 'Task')
choice.choice_items.create!(name: 'Meeting')

choice = Choice.create!(name: 'activity_status_type')
choice.choice_items.create!(name: 'Not started')
choice.choice_items.create!(name: 'In progress')
choice.choice_items.create!(name: 'Completed')
choice.choice_items.create!(name: 'Discarded')

choice = Choice.create!(name: 'survey_type')
choice.choice_items.create!(name: 'Feedback')
choice.choice_items.create!(name: 'Survey')
choice.choice_items.create!(name: 'Workbook')

choice = Choice.create!(name: 'survey_expedition_type')
choice.choice_items.create!(name: 'Feedback')
choice.choice_items.create!(name: 'Survey')
choice.choice_items.create!(name: 'Workbook')

choice = Choice.create!(name: 'survey_activity_type')
choice.choice_items.create!(name: 'Feedback')
choice.choice_items.create!(name: 'Survey')
choice.choice_items.create!(name: 'Workbook')

choice = Choice.create!(name: 'survey_status_type')
choice.choice_items.create!(name: 'Draft')
choice.choice_items.create!(name: 'Published')
choice.choice_items.create!(name: 'Completed')
choice.choice_items.create!(name: 'Discarded')

choice = Choice.create!(name: 'survey_page_type')
choice.choice_items.create!(name: 'Fullscreen')
choice.choice_items.create!(name: 'Embedded')

choice = Choice.create!(name: 'survey_question_item_type')
choice.choice_items.create!(name: 'Text')
choice.choice_items.create!(name: 'Numeric')
choice.choice_items.create!(name: 'Dropdown')
choice.choice_items.create!(name: 'Radio')
choice.choice_items.create!(name: 'Checkbox')
choice.choice_items.create!(name: 'Range')

choice = Choice.create!(name: 'survey_response_status_type')
choice.choice_items.create!(name: 'Not Started')
choice.choice_items.create!(name: 'Started')
choice.choice_items.create!(name: 'Completed')
choice.choice_items.create!(name: 'Discarded')

choice = Choice.create!(name: 'feedback_rating1_type')
choice.choice_items.create!(name: 'Great')
choice.choice_items.create!(name: 'Ok')
choice.choice_items.create!(name: 'Whatever')
choice.choice_items.create!(name: 'Horrible')

# Create users
# ------------------------------------------------
user_role_choice = Choice.find_by!(name: 'user_role_type')
role_admin = user_role_choice.choice_items.find_by!(name: 'administrator')
role_staff = user_role_choice.choice_items.find_by!(name: 'staff')
role_subscriber = user_role_choice.choice_items.find_by!(name: 'subscriber')
role_explorer = user_role_choice.choice_items.find_by!(name: 'explorer')

# Create users
WE = Organisation.create!(name: "Women Emerging", organisation_type: 'Community')
UnknownOrg = Organisation.create!(name: "Unknown", organisation_type: 'Community')

admin = User.create!(
  email: 'admin@wehub.com',
  first_name: 'Admin',
  last_name: 'Wehub',
  password: 'testadmin',
  password_confirmation: 'testadmin',
  nationality: 'United States of America',
  country: 'United States of America',
  organisation: WE
)
admin.user_role_choice_items.create!(choice_item: role_admin)

staff = User.create!(
  email: 'staff@wehub.com',
  first_name: 'Staff',
  last_name: 'Wehub',
  password: 'teststaff',
  password_confirmation: 'teststaff',
  nationality: 'United States of America',
  country: 'United States of America',
  organisation: WE
)
staff.user_role_choice_items.create!(choice_item: role_staff)




# Create organizations
# ------------------------------------------------
# organisations = []
#
# organisations[0] = Organisation.create!(name: "Synapse",
#                                         organisation_type: 'Corporate')
# organisations[1] = Organisation.create!(name: "Pathfinder",
#                                         organisation_type: 'Corporate')
# organisations[2] = Organisation.create!(name: "PARCO",
#                                         organisation_type: 'Corporate')
# organisations[3] = Organisation.create!(name: "Schlumberger",
#                                         organisation_type: 'Corporate')
# organisations[4] = Organisation.create!(name: "Tapal",
#                                         organisation_type: 'Corporate')
# organisations[5] = Organisation.create!(name: "KE",
#                                         organisation_type: 'Corporate')
# Organisation.create!(name: "Ismail Industries",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Faysal Funds",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Teach for Nigeria",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "University of Illinois",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "University of Connecticut",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "University of Illinois Urbana-Champaign",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Universal AI University",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Qatar University",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "ESCA School of Management",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Qatar University",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Ghana Institute of Management and public administration",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Universidad de los Andes",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "GBSN",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Re:wild",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "WOW Foundation",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "WIRE",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Hitachi Energy",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Youthtopia",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "ACCORD",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Buzz Women",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Equilead",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "Edelgive",
#                      organisation_type: 'Corporate')
# Organisation.create!(name: "40 Under 40",
#                      organisation_type: 'Corporate')
#
#
# locations = []
# (0..10).each do |i|
#   locations[i] = Location.create!(name: "Location#{i}",
#                                   address: "123#{i} High Street",
#                                   organisation: organisations[i],
#                                   city: 'London',
#                                   postal_code: 'SW1 1AA',
#                                   phone: '020 1234 5678',
#                                   location_type: 'Corporate Location')
# end

# Create skeletons
# ------------------------------------------------
skeleton = Expedition.create!(name: 'Group', expedition_type: 'Group',
                              expedition_phase_type: 'Kick-off',
                              start_date: Time.zone.today,
                              end_date: Time.zone.today + 30,
                              is_skeleton: true)

phases = {}
%w[Kick-off Recruitment Preparation Delivery Dissemination].each do |phase|
  phases[phase] = skeleton.expedition_phases.create!(name: phase)
end
activity_types = Choice.find_by!(name: 'activity_type').choice_items.index_by(&:name)
activity_statuses = Choice.find_by!(name: 'activity_status_type').choice_items.index_by(&:name)



skeleton.activities.create!(name: 'BD delivers handover to the expedition team',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Agree partner management process',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Assign/recruit Community Manager and Expedition Leader',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Complete project plan',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Schedule internal team weekly check-ins',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Share project plan, roles & responsibilities with partners and team',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Delivery team kickoff meeting',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Draft copy /flyer for Marketing',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Request marketing materials',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Marketing materials ready',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Launch recruitment',
                            expedition_phase: phases['Kick-off'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)


skeleton.activities.create!(name: 'Decide eligibility criteria',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Decide dates and times for all calls including the orientation',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Edit application form',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add form link to flyer',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'First recruitment post on social media',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create a list of the possible expedition members or nominators',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email to possible expedition members and nominators',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Schedule weekly check in with WE team - 30 minute call',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Bi-weekly update email with partners',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review applications',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create a shortlist with the chosen people',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Second review of applications by Expedition Leader',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Email those not eligible',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Email the chosen people to be the expedition members',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Confirm with chosen applicants',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Email team and partners to confirm group finalised',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create a final list with the chosen expedition members',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create a spreadsheet with members & partners details',
                            expedition_phase: phases['Recruitment'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)



skeleton.activities.create!(name: 'Welcome-email to all expedition members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create Zoom link and share Outlook invite to expedition members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% of bios and photos of expedition members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% of bios and photos of expedition members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% of Mutual Agreement and Marketing Consent letter from members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% of Mutual Agreement and Marketing Consent letter from members',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Confirm attendance for onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email to explorers who have yet to provide agreement,bios and consent ',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase non-responsive applicants',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create team brief for onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Schedule team preparation call for onboarding ',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Edit team brief ahead of onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create welcome page with explorer photos and names',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create Canva design templates for Call 1 to 7 for explorer reflections',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send explorers email reminder for onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send explorers email reminder for onboarding call on WhatsApp 30 minutes before call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Deliver onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download and edit recording and save on Vimeo',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post onboarding email to explorers',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email nudging explorers to submit questions for Julia on WhatsApp',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send team/partner email post onboarding - numbers and updates',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Follow up with who might not have joined the onboarding call',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% of pre expedition survey',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% of pre expedition survey',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: '100% explorers joined WhatsApp group',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Marketing provides announcement photos and document for optional captions',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Share photos with explorers',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create Google Drive folder for expedition',
                            expedition_phase: phases['Preparation'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)



skeleton.activities.create!(name: 'Collect 4 E\'s questions for Julia',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 1 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 1 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 1 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 1 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 1',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 1 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 2 email, 1 week before Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 2, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 2, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Send email reminder for Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 2 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 2 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 2 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 2 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 2 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 2 email, 1 week before Call 2',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 2, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 2, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)


skeleton.activities.create!(name: 'Send email reminder for Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 3 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 3 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 3 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 3 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 3 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 3 email, 1 week before Call 3',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 3, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 3, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)



skeleton.activities.create!(name: 'Send email reminder for Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 4 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 4 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 4 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 4 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 4 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 4 email, 1 week before Call 4',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 4, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 4, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)



skeleton.activities.create!(name: 'Send email reminder for Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 5 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 5 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 5 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 5 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 5 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 5 email, 1 week before Call 5',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 5, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 5, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Send email reminder for Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 6 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 6 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 6 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 6 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 6 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 6 email, 1 week before Call 6',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 6, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 6, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Send email reminder for Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Consolidate apologies for Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Develop team brief for Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Julia meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Preparation meeting with Expedition Leader',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Update team brief and Google Drive folder',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 7 with Zoom link, day before the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 7 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Record the Zoom meeting Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Take notes on attendace during Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send post Call 7 email to explorers, immediately after call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect feedback from 50% of those who attended the call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Download, trim the recording & save it on Vimeo',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send recording of  Call 7 to expedition members who couldn\'t join',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for explore brief on WhatsApp, 1 weeks after Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send reminder for reflection submissions, 2 weeks after Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send individuals WhatsApp to ask if they understood the explore brief & check progress',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 50% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Save reflections on drive as recieved (not in view of explorers)',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Chase individuals who have not submitted reflections via WhatsApp',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect 100% reflections from expedition members',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Add the reflections to Call 7 template on Canva',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send Pre-Call 7 email, 1 week before Call 7',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send email reminder for Call 7, 1 day before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send WhatsApp reminder for Call 7, 30 minutes before call',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Review any possible content for Marketing',
                            expedition_phase: phases['Delivery'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)


skeleton.activities.create!(name: 'Send congatulations-emails to the expedition members',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send thank you-emails to partners',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send questionnaire to the expedition members',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send instructions by email for the questionnaire',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send instructions on the dissemination plan to the members',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect expedition members ideas on the dissemination plan',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create social media posts about the completion of the expedition',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Collect questionnaire responses',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Create graphical illustrations of the questionnaire responses',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Follow up with who might need assistance with the dissemination plan',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Send instructions by email for the questionnaire after 6 months',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton.activities.create!(name: 'Collect questionnaire responses',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Create graphical illustrations of the questionnaire responses',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Write a report for the expedition',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send the report by email to the expedition members, guides & partners',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Send thank you-emails to partners, guides and members',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton.activities.create!(name: 'Put contact details of partners, members and guides in CRM',
                            expedition_phase: phases['Dissemination'],
                            activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)


=begin

(0..7).each do |i|
  skeleton.activities.create!(name: "Expedition Session #{i}",
                              expedition_phase: phases['Delivery'],
                              activity_type: 'Meeting',
                              activity_status_type_id: activity_statuses['Not started'].id)
end
=end

skeleton_solo = Expedition.create!(name: 'Solo', expedition_type: 'Solo',
                                   expedition_phase_type: 'Active',
                                   start_date: Time.zone.today,
                                   end_date: Time.zone.today + 30,
                                   is_skeleton: true)


phases = {}
['Active'].each do |phase|
  phases[phase] = skeleton_solo.expedition_phases.create!(name: phase)
end

skeleton_solo.activities.create!(name: 'Add explorer to solo expedition platform',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton_solo.activities.create!(name: 'Send welcome email inclusive of onboarding information',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton_solo.activities.create!(name: 'Confirm receipt of agreement',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton_solo.activities.create!(name: 'Confirm receipt of survey',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton_solo.activities.create!(name: 'Activate online solo expedition content',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton_solo.activities.create!(name: 'Progress email one',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton_solo.activities.create!(name: 'Progress email two',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton_solo.activities.create!(name: 'Completion email and social media shareable',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
skeleton_solo.activities.create!(name: 'Alumni email and next steps',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton_solo.activities.create!(name: 'Add to All Explorers platform',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)

skeleton_solo.activities.create!(name: 'Mark as ‘Alumni’',
                                 expedition_phase: phases['Active'],
                                 activity_type_id: activity_types['Task'].id, activity_status_type_id: activity_statuses['Not started'].id)
# Create expeditions using skeleton
# ------------------------------------------------
# expeditions = []
# (0..3).each do |i|
#   expeditions[i] = Expedition.create_from_skeleton("Expedition#{i}",
#                                                    Time.zone.today - 2.weeks,
#                                                    Time.zone.today + 2.weeks,
#                                                    manager,
#                                                    leader,
#                                                    skeleton)
#
#   expeditions[i].expedition_organisations.create!(organisation: organisations[i],
#                                                   expedition_organisation_type: 'partner')
#   expeditions[i].expedition_users.create!(user: subscribers[i], expedition_role_type: 'subscribers')
#   expeditions[i].expedition_users.create!(user: staff, expedition_role_type: 'manager')
# #   (0..8).each do |j|
# #     expeditions[i].expedition_users.create!(user: users[(i * 10) + j],
# #                                             expedition_role_type: 'explorer')
# #   end
#  end
#
# # add some fields to expedition0
# desc = %(
# <h2 style="text-align: center;"><span style="color: rgb(35, 111, 161);">EXPEDITION ZERO</span></h2>
# <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed id ipsum bibendum, dapibus tellus quis, fermentum libero. Nulla elit erat, luctus consectetur faucibus sit amet, interdum eu ante. </p>
# <ul>
# <li><em>&ldquo;Julia Middleton&nbsp;has&nbsp;produced&nbsp;a&nbsp;fascinating&nbsp;series&nbsp;filled with wisdom, humour,&nbsp;myth-busting,&nbsp;and&nbsp;love.&nbsp;The Women Emerging podcast is a masterclass on how to let&nbsp;authentic voices shine.&rdquo; Amy Stillman</em></li>
# </ul>
# )
#
# expeditions[0].update!(funded_amount: 1000,
#                        start_date: Time.zone.today - 1.week,
#                        end_date: Time.zone.today + 6.weeks,
#                        expedition_phase_type: 'Recruitment',
#                        description: desc,
#                        is_platform_created: true,
#                        is_marketing_completed: true)
# expeditions[0].expedition_phases.create!(name: 'Development')
# dev_phase = expeditions[0].expedition_phases.find_by!(name: 'Development')
# if dev_phase
#   dev_phase.update!(is_completed: true, start_date: Time.zone.today - 1.week,
#                     end_date: Time.zone.today)
#
#   dev_activity = dev_phase.activities.find_by(name: 'Create a final list with the chosen expedition members')
#   dev_activity&.update!(activity_status_type: 'Completed', start_date: Time.zone.today - 1.week,
#                         completion_date: Time.zone.today, assigned_user: staff)
# end
# r_phase = expeditions[0].expedition_phases.find_by(name: 'Recruitment')
# r_phase.update!(start_date: Time.zone.today, end_date: Time.zone.today + 1.week)
#
# welcome_activity = expeditions[0].activities&.find_by(name: 'Email the chosen people to be the expedition members')
# if staff.present?
#   a_content = Content.create!(content_type: 'Email',
#                               name: 'Welcome Email',
#                               author: staff,
#                               content: '<h1>Thank you for joining the expedition</h1>')
# end
# welcome_activity&.activity_contents&.create!(content: a_content)
#
# # # And some other expedition types
# # exp_solo_1 = Expedition.create_from_skeleton('Solo Expedition 1',
# #                                              Time.zone.today - 2.weeks,
# #                                              Time.zone.today + 2.weeks,
# #                                              manager,
# #                                              leader,
# #                                              skeleton_solo)
# #
# # exp_solo_1.expedition_users.create!(user: users[6], expedition_role_type: 'explorer')
# #
# # exp_solo_2 = Expedition.create_from_skeleton('Solo Expedition 2',
# #                                              Time.zone.today - 2.weeks,
# #                                              Time.zone.today + 2.weeks,
# #                                              manager,
# #                                              leader,
# #                                              skeleton_solo)
# # exp_solo_2.update!(
# #   expedition_phase_type: 'Active',
# #   is_approved: true
# # )
# # A_phase = exp_solo_2.expedition_phases.find_by(name: 'Active')
# # A_phase.update!(start_date: Time.zone.today - 2.weeks, end_date: Time.zone.today - 1.week,
# #                 is_completed: true)
# # A_phase.activities.first.update!(activity_status_type: 'Completed')
# # # exp_solo_2.expedition_users.create!(user: users[68], expedition_role_type: 'explorer')
#
# # Create some surveys
# # # ------------------------------------------------
# # survey = Survey.create!(name: 'Survey1', survey_type: 'Feedback', author: staff)
# # pg = survey.survey_pages.create!(name: 'Page 1', survey_page_type: 'Fullscreen',
# #                                  content: 'Thank you for taking the time to complete this survey')
# # pg.survey_questions.create!(name: 'Question 1',
# #                             label: 'Please rate your experience',
# #                             choice_name: 'feedback_rating1_type',
# #                             survey_question_item_type: 'Radio')
# # pg.survey_questions.create!(name: 'Question 2',
# #                             label: 'What did you like best?',
# #                             survey_question_item_type: 'Text')
# # # rsp = survey.survey_responses.create!(user: users[9], survey_response_status_type: 'Started')
# # # rsp.survey_answers.create!(survey_question: pg.survey_questions.first,
# # #                            string_answer: 'Great')
# # # rsp.survey_answers.create!(survey_question: pg.survey_questions.last,
# # #                            string_answer: 'The food')
# #
# # cont = %(
# # <div><span style="color: rgb(224, 62, 45);">
# # <strong><em>Thank you for taking the time to complete this survey!</em></strong>
# # </span></div>
# # )
# #
# # survey = Survey.create!(name: 'Survey2', survey_type: 'Feedback', author: staff)
# pg = survey.survey_pages.create!(name: 'Page 1', survey_page_type: 'Fullscreen',
#                                  content: cont)
# pg.survey_questions.create!(name: 'Rate experience',
#                             label: 'Please rate your experience',
#                             choice_name: 'feedback_rating1_type',
#                             survey_question_item_type: 'Radio')
# pg.survey_questions.create!(name: 'Like best?',
#                             label: 'What did you like best?',
#                             survey_question_item_type: 'Text')
# pg = survey.survey_pages.create!(name: 'Page 2', survey_page_type: 'Fullscreen',
#                                  content: 'Thank you for taking the time to complete this survey')
# pg.survey_questions.create!(name: 'Rate food',
#                             label: 'Please rate the food',
#                             choice_name: 'feedback_rating1_type',
#                             survey_question_item_type: 'Radio')
# pg.survey_questions.create!(name: 'Like best?',
#                             label: 'What did you like best?',
#                             survey_question_item_type: 'Text')
# rsp = survey.survey_responses.create!(user: users[19], survey_response_status_type: 'Started')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.first,
#                            string_answer: 'Horrible')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.last,
#                            string_answer: 'The go carts')
# rsp = survey.survey_responses.create!(user: users[12], survey_response_status_type: 'Started')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.first,
#                            string_answer: 'Ok')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.last,
#                            string_answer: 'The tap dancing')
# rsp = survey.survey_responses.create!(user: users[17], survey_response_status_type: 'Started')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.first,
#                            string_answer: 'Ok')
# rsp.survey_answers.create!(survey_question: pg.survey_questions.last,
#                            string_answer: 'Rest period')
