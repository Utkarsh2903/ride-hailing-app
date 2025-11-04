# Concern for consistent JSON API rendering
module JsonapiRenderable
  extend ActiveSupport::Concern

  private

  # Success response
  def render_success(data = {}, status: :ok, meta: {})
    render json: {
      success: true,
      data: data,
      meta: meta
    }, status: status
  end

  # Error response (use this for manual errors)
  def render_error(message, status: :bad_request, code: nil, details: {})
    render json: {
      success: false,
      error: {
        code: code || status.to_s,
        message: message,
        details: details
      }
    }, status: status
  end

  # Collection response with pagination
  def render_collection(collection, serializer:, meta: {})
    render json: {
      success: true,
      data: serializer.new(collection).serializable_hash,
      meta: meta.merge(pagination_meta(collection))
    }
  end

  # Pagination metadata
  def pagination_meta(collection)
    return {} unless collection.respond_to?(:current_page)

    {
      pagination: {
        current_page: collection.current_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: collection.limit_value
      }
    }
  end
end
