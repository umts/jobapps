module ApplicationTemplatesHelper
  def template_link(text, dept, pos)
    return link_to('Invalid link', '#') unless
      Department.exists?(dept.id) && Position.exists?(pos.id)
    dept_name = Department.find(dept.id).name
    pos_name = Position.find(pos.id).name
    link_to text, application_show_path(dept_name, pos_name)
  end
end
