class Roster::CellCarriersController < ApplicationController
  before_action :set_roster_cell_carrier, only: [:show, :edit, :update, :destroy]

  # GET /roster/cell_carriers
  # GET /roster/cell_carriers.json
  def index
    @roster_cell_carriers = Roster::CellCarrier.all
  end

  # GET /roster/cell_carriers/1
  # GET /roster/cell_carriers/1.json
  def show
  end

  # GET /roster/cell_carriers/new
  def new
    @roster_cell_carrier = Roster::CellCarrier.new
  end

  # GET /roster/cell_carriers/1/edit
  def edit
  end

  # POST /roster/cell_carriers
  # POST /roster/cell_carriers.json
  def create
    @roster_cell_carrier = Roster::CellCarrier.new(roster_cell_carrier_params)

    respond_to do |format|
      if @roster_cell_carrier.save
        format.html { redirect_to @roster_cell_carrier, notice: 'Cell carrier was successfully created.' }
        format.json { render action: 'show', status: :created, location: @roster_cell_carrier }
      else
        format.html { render action: 'new' }
        format.json { render json: @roster_cell_carrier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roster/cell_carriers/1
  # PATCH/PUT /roster/cell_carriers/1.json
  def update
    respond_to do |format|
      if @roster_cell_carrier.update(roster_cell_carrier_params)
        format.html { redirect_to @roster_cell_carrier, notice: 'Cell carrier was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @roster_cell_carrier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roster/cell_carriers/1
  # DELETE /roster/cell_carriers/1.json
  def destroy
    @roster_cell_carrier.destroy
    respond_to do |format|
      format.html { redirect_to roster_cell_carriers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_roster_cell_carrier
      @roster_cell_carrier = Roster::CellCarrier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def roster_cell_carrier_params
      params.require(:roster_cell_carrier).permit(:name, :sms_gateway)
    end
end
