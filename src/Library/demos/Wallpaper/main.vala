#!/usr/bin/env -S vala workbench.vala --pkg libadwaita-1 --pkg libportal-gtk4

private Xdp.Portal portal;
private Xdp.Parent parent;
private Gtk.Button button;
private File file;

public void main () {
  portal = new Xdp.Portal ();
  parent = Xdp.parent_new_gtk (workbench.window);

  // FIXME: Not sure if pkg.pkgdatadir is accessible from the Vala API
  string file_path = Path.build_filename (Environment.get_user_data_dir (), "Library/demos/Wallpaper/wallpaper.png");
  file = File.new_for_path (file_path);

  button = (Gtk.Button) workbench.builder.get_object ("button");
  button.clicked.connect (on_button_clicked);
}

private async void on_button_clicked () {
  try {
    bool success = yield portal.set_wallpaper (
      parent,
      file.get_uri (),
      PREVIEW | BACKGROUND | LOCKSCREEN,
      null
    );

    if (success) {
      message ("Wallpaper set successfully");
    } else {
      message ("Could not set wallpaper");
    }
  }
  catch (Error e) {
    critical (e.message);
  }
}
