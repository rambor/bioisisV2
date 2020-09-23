module SubmissionsHelper


  def total_comments(submission)
    # t.boolean "resolved", default: false
    # t.boolean "posted", default: false
    not_resolved_count = 0
    submission.comments.each do |comment|
      not_resolved_count += (comment.resolved) ? 0 : 1;
    end
    return not_resolved_count;
  end

end
