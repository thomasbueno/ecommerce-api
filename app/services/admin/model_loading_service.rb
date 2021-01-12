module Admin
  class ModelLoadingService
    attr_reader :records, :pagination

    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params || {}
      @records = []
      @pagination = { page: @params[:page].to_i, length: @params[:length].to_i }
    end

    def call
      fix_pagination_values
      filtered = search_records(@searchable_model)
      @records = filtered.order(@params[:order].to_h)
      .paginate(@pagination[:page], @pagination[:length])

      total_pages = (filtered.count / @pagination[:length].to_f).ceil
      @pagination.merge!(total: filtered.count, total_pages: total_pages)
    end

    private

    def fix_pagination_values
      @pagination[:page] = @searchable_model.model::DEFAULT_PAGE if @pagination[:page] <= 0
      @pagination[:length] = @searchable_model.model::MAX_PER_PAGE if @pagination[:length] <= 0
    end

    def search_records(searched)
      return searched unless @params.has_key?(:search)
      @params[:search].each do |key, value|
        searched = searched.like(key, value)
      end
      searched
    end
  end
end