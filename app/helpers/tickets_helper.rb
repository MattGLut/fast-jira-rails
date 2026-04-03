module TicketsHelper
  def priority_badge_class(priority)
    {
      "critical" => "bg-red-500/20 text-red-300 border border-red-400/40",
      "high" => "bg-orange-500/20 text-orange-300 border border-orange-400/40",
      "medium" => "bg-yellow-500/20 text-yellow-300 border border-yellow-400/40",
      "low" => "bg-emerald-500/20 text-emerald-300 border border-emerald-400/40"
    }.fetch(priority.to_s, "bg-gray-700 text-gray-200 border border-gray-600")
  end

  def type_icon(ticket_type)
    {
      "story" => "📖",
      "task" => "✅",
      "bug" => "🐛"
    }.fetch(ticket_type.to_s, "🎫")
  end

  def status_badge_class(status)
    {
      "todo" => "bg-slate-500/20 text-slate-200 border border-slate-400/40",
      "in_progress" => "bg-sky-500/20 text-sky-200 border border-sky-400/40",
      "code_review" => "bg-violet-500/20 text-violet-200 border border-violet-400/40",
      "qa" => "bg-amber-500/20 text-amber-200 border border-amber-400/40",
      "done" => "bg-emerald-500/20 text-emerald-200 border border-emerald-400/40"
    }.fetch(status.to_s, "bg-gray-700 text-gray-100 border border-gray-600")
  end
end
