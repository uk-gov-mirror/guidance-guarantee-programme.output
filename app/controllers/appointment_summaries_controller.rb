# frozen_string_literal: true
class AppointmentSummariesController < ApplicationController
  before_action :authenticate_as_team_leader!, only: :index
  before_action :check_can_create_appointments!, only: [:new, :confirm, :create]
  before_action :load_summary, only: %i(new email_confirmation update confirm)

  def index
    @appointment_form = AppointmentSummaryFinder.new(
      search_string: params.dig(:appointment_summary_finder, :search_string),
      search_date: params.dig(:appointment_summary_finder, :search_date)
    )
  end

  def new
    if telephone_appointment? && no_summary_provided?
      render :summarise_via_tap
    else
      @appointment_summary.assign_attributes(appointment_summary_params)
    end
  end

  def confirm
    @appointment_summary.assign_attributes(appointment_summary_params)

    if @appointment_summary.valid?
      @output_document = OutputDocument.new(@appointment_summary)
    else
      render :new
    end
  end

  def create
    @appointment_summary = AppointmentSummary.create!(appointment_summary_params)
    send_notifications(@appointment_summary)

    respond_to do |format|
      format.html { redirect_to done_appointment_summaries_path }
      format.json { render json: ajax_response_paths(@appointment_summary) }
    end
  end

  def update
    @appointment_summary.update!(appointment_summary_params)
    send_notifications(@appointment_summary)

    respond_to do |format|
      format.html { redirect_to done_appointment_summaries_path }
      format.json { render json: ajax_response_paths(@appointment_summary) }
    end
  end

  def show
    appointment_summary = AppointmentSummary.find(params[:id])
    output_document = OutputDocument.new(appointment_summary)

    send_data output_document.pdf,
              filename: 'pension_wise.pdf', type: 'application/pdf',
              disposition: :inline
  end

  def done
  end

  def creating
  end

  private

  def check_can_create_appointments!
    authorise_user!(any_of: [User::TELEPHONE_APPOINTMENT_PERMISSION, User::FACE_TO_FACE_PERMISSION])
  end

  def load_summary
    @appointment_summary = AppointmentSummary.find_or_initialize_by(
      reference_number: params.dig(:appointment_summary, :reference_number)
    )
  end

  def send_notifications(appointment_summary)
    CreateTapActivity.perform_later(appointment_summary, current_user) if telephone_appointment?
    NotifyViaEmail.perform_later(appointment_summary) if appointment_summary.can_be_emailed?
  end

  def no_summary_provided?
    !params.key?(:appointment_summary)
  end

  def telephone_appointment?
    current_user.has_permission?(User::TELEPHONE_APPOINTMENT_PERMISSION)
  end
  helper_method :telephone_appointment?

  def appointment_summary_params
    params
      .fetch(:appointment_summary, {})
      .permit(AppointmentSummary.editable_column_names)
      .merge(user: current_user, telephone_appointment: telephone_appointment?)
      .reverse_merge(date_of_appointment: Date.current)
  end

  def ajax_response_paths(appointment_summary)
    {
      done_path: done_appointment_summaries_path,
      pdf_path: appointment_summary_path(appointment_summary, format: 'pdf')
    }
  end
end
