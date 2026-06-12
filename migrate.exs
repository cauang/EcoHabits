defmodule Migrator do
  def copy_dir(src, dest) do
    File.mkdir_p!(dest)
    File.ls!(src)
    |> Enum.each(fn file ->
      src_path = Path.join(src, file)
      dest_path = Path.join(dest, file)
      
      if File.dir?(src_path) do
        copy_dir(src_path, dest_path)
      else
        File.cp!(src_path, dest_path)
      end
    end)
  end
end

base = "C:\\EcoHabits"
src_base = Path.join(base, "ModuloC-JoaoVictor")

# 1. Copiar Migrations (arquivos específicos)
File.ls!(Path.join([src_base, "priv", "repo", "migrations"]))
|> Enum.each(fn file ->
  src_path = Path.join([src_base, "priv", "repo", "migrations", file])
  dest_path = Path.join([base, "priv", "repo", "migrations", file])
  if File.regular?(src_path) and file != ".formatter.exs" do
    File.cp!(src_path, dest_path)
  end
end)

# 2. Copiar lib/ecohabits/habitos/
Migrator.copy_dir(Path.join([src_base, "lib", "ecohabits", "habitos"]), Path.join([base, "lib", "ecohabits", "habitos"]))

# 3. Copiar lib/ecohabits/habitos.ex
File.cp!(Path.join([src_base, "lib", "ecohabits", "habitos.ex"]), Path.join([base, "lib", "ecohabits", "habitos.ex"]))

# 4. Copiar lib/ecohabits_web/live/habito_live/
Migrator.copy_dir(Path.join([src_base, "lib", "ecohabits_web", "live", "habito_live"]), Path.join([base, "lib", "ecohabits_web", "live", "habito_live"]))

# 5. Copiar dashboard_live.ex e feed_live.ex
File.cp!(Path.join([src_base, "lib", "ecohabits_web", "live", "dashboard_live.ex"]), Path.join([base, "lib", "ecohabits_web", "live", "dashboard_live.ex"]))
File.cp!(Path.join([src_base, "lib", "ecohabits_web", "live", "feed_live.ex"]), Path.join([base, "lib", "ecohabits_web", "live", "feed_live.ex"]))

# 6. Sobrescrever arquivos vitais
File.cp!(Path.join([src_base, "lib", "ecohabits", "accounts", "user.ex"]), Path.join([base, "lib", "ecohabits", "accounts", "user.ex"]))
File.cp!(Path.join([src_base, "lib", "ecohabits", "accounts.ex"]), Path.join([base, "lib", "ecohabits", "accounts.ex"]))
File.cp!(Path.join([src_base, "lib", "ecohabits_web", "components", "layouts.ex"]), Path.join([base, "lib", "ecohabits_web", "components", "layouts.ex"]))
File.cp!(Path.join([src_base, "lib", "ecohabits_web", "router.ex"]), Path.join([base, "lib", "ecohabits_web", "router.ex"]))
File.cp!(Path.join([src_base, "lib", "ecohabits", "application.ex"]), Path.join([base, "lib", "ecohabits", "application.ex"]))

# 7. Apagar a pasta antiga
File.rm_rf!(src_base)

IO.puts "Migração de arquivos concluída e pasta ModuloC-JoaoVictor removida com sucesso!"
