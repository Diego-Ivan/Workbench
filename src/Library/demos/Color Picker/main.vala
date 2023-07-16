#!/usr/bin/env -S vala workbench.vala --pkg libadwaita-1 --pkg libportal-gtk4

private Xdp.Portal portal;
private Xdp.Parent parent;
private Gtk.Button button;

public void main () {
  portal = new Xdp.Portal ();
  parent = Xdp.parent_new_gtk (workbench.window);
  button = (Gtk.Button) workbench.builder.get_object ("button");

  button.clicked.connect (on_button_clicked);
}

public async void on_button_clicked () {
  try {
    // result is a Variant of the form (ddd), containing red, green and blue components in the range [0,1]
    Variant colors = yield portal.pick_color (parent, null);
    double red = 0, green = 0, blue = 0;

    VariantIter iter = colors.iterator ();
    iter.next ("d", &red);
    iter.next ("d", &green);
    iter.next ("d", &blue);

    Gdk.RGBA color = { (float) red, (float) green, (float) blue, 1f};
    message ("The selected color is %s", color.to_string ());
  }
  catch (Error e) {
    error (e.message);
  }
}
