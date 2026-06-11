defmodule EcohabitsWeb.UserSessionHTML do
  use EcohabitsWeb, :html

  # Força a importação explícita dos componentes visuais (simple_form, input, button)
  import EcohabitsWeb.CoreComponents

  embed_templates "user_session_html/*"
end