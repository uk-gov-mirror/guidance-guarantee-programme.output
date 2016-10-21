require 'rails_helper'

RSpec.describe AppointmentSummaryCsv do
  let(:appointment) { create(:appointment_summary) }
  let(:separator) { ',' }

  subject { described_class.new(appointment).call.lines }

  describe '#csv' do
    it 'generates headings' do
      expect(subject.first.chomp.split(separator)).to match_array(
        %w(
          id
          date_of_appointment
          value_of_pension_pots_is_approximate
          count_of_pension_pots
          value_of_pension_pots
          upper_value_of_pension_pots
          guider_name
          reference_number
          address_line_1
          address_line_2
          address_line_3
          town
          county
          postcode
          country
          title
          first_name
          last_name
          format_preference
          appointment_type
          has_defined_contribution_pension
          supplementary_benefits
          supplementary_debt
          supplementary_ill_health
          supplementary_defined_benefit_pensions
          continue_working
          unsure
          leave_inheritance
          wants_flexibility
          wants_security
          wants_lump_sum
          poor_health
          requested_digital
          number_of_previous_appointments
          created_at
          email
          notification_id
          retirement_income_other_state_benefits
          retirement_income_employment
          retirement_income_partner
          retirement_income_interest_or_savings
          retirement_income_property
          retirement_income_business
          retirement_income_inheritance
          retirement_income_other_income
          retirement_income_unspecified
          retirement_income_defined_benefit
        )
      )
    end

    it 'generates correctly mapped rows' do
      expect(subject.last.chomp.split(separator, -1)).to eq(
        [
          appointment.to_param,
          appointment.date_of_appointment.to_s,
          appointment.value_of_pension_pots_is_approximate.to_s,
          appointment.count_of_pension_pots.to_s,
          appointment.value_of_pension_pots.to_s,
          appointment.upper_value_of_pension_pots.to_s,
          appointment.guider_name,
          appointment.reference_number,
          appointment.address_line_1,
          appointment.address_line_2,
          appointment.address_line_3,
          appointment.town,
          appointment.county,
          appointment.postcode,
          appointment.country,
          appointment.title,
          appointment.first_name,
          appointment.last_name,
          appointment.format_preference,
          appointment.appointment_type,
          appointment.has_defined_contribution_pension.to_s,
          appointment.supplementary_benefits.to_s,
          appointment.supplementary_debt.to_s,
          appointment.supplementary_ill_health.to_s,
          appointment.supplementary_defined_benefit_pensions.to_s,
          appointment.continue_working.to_s,
          appointment.unsure.to_s,
          appointment.leave_inheritance.to_s,
          appointment.wants_flexibility.to_s,
          appointment.wants_security.to_s,
          appointment.wants_lump_sum.to_s,
          appointment.poor_health.to_s,
          appointment.requested_digital.to_s,
          appointment.number_of_previous_appointments.to_s,
          appointment.created_at.getlocal.to_s(:rfc),
          appointment.email,
          quote_empty_string(appointment.notification_id),
          appointment.retirement_income_other_state_benefits.to_s,
          appointment.retirement_income_employment.to_s,
          appointment.retirement_income_partner.to_s,
          appointment.retirement_income_interest_or_savings.to_s,
          appointment.retirement_income_property.to_s,
          appointment.retirement_income_business.to_s,
          appointment.retirement_income_inheritance.to_s,
          appointment.retirement_income_other_income.to_s,
          appointment.retirement_income_defined_benefit.to_s,
          appointment.retirement_income_unspecified.to_s
        ]
      )
    end

    def quote_empty_string(value)
      value == '' ? '""' : value
    end
  end
end
