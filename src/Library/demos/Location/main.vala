#!/usr/bin/env -S vala workbench.vala --pkg libadwaita-1 --pkg libportal-gtk4

private Xdp.Portal portal;
private Xdp.Parent parent;

private Gtk.Revealer revealer;
private Gtk.Button start;
private Gtk.Button close_button;
private Gtk.SpinButton distance_spinbutton;
private Gtk.SpinButton time_spinbutton;
private Adw.ComboRow accuracy_button;

private Gtk.Label latitude_label;
private Gtk.Label longitude_label;
private Gtk.Label accuracy_label;
private Gtk.Label altitude_label;
private Gtk.Label speed_label;
private Gtk.Label heading_label;
private Gtk.Label description_label;
private Gtk.Label timestamp_label;

private Xdp.LocationAccuracy accuracy = EXACT;
private uint distance_threshold = 0u;
private uint time_threshold = 0u;

public void main () {
  portal = new Xdp.Portal ();
  parent = Xdp.parent_new_gtk (workbench.window);

  revealer = (Gtk.Revealer) workbench.builder.get_object ("revealer");
  start = (Gtk.Button) workbench.builder.get_object ("start");
  close_button = (Gtk.Button) workbench.builder.get_object ("close");
  distance_spinbutton = (Gtk.SpinButton) workbench.builder.get_object ("distance_threshold");
  time_spinbutton = (Gtk.SpinButton) workbench.builder.get_object ("time_threshold");
  accuracy_button = (Adw.ComboRow) workbench.builder.get_object ("accuracy_button");

  latitude_label = (Gtk.Label) workbench.builder.get_object ("latitude");
  longitude_label = (Gtk.Label) workbench.builder.get_object ("longitude");
  accuracy_label = (Gtk.Label) workbench.builder.get_object ("accuracy");
  altitude_label = (Gtk.Label) workbench.builder.get_object ("altitude");
  speed_label = (Gtk.Label) workbench.builder.get_object ("speed");
  heading_label = (Gtk.Label) workbench.builder.get_object ("heading");
  description_label = (Gtk.Label) workbench.builder.get_object ("description");
  timestamp_label = (Gtk.Label) workbench.builder.get_object ("timestamp");

  time_spinbutton.value_changed.connect (() => {
    portal.location_monitor_stop ();
    revealer.reveal_child = false;
    time_threshold = (uint) time_spinbutton.value;
    message ("Time threshold changed");
    start_session.begin ();
  });

  distance_spinbutton.value_changed.connect (() => {
    portal.location_monitor_stop ();
    revealer.reveal_child = false;
    distance_threshold = (uint) distance_spinbutton.value;
    message ("Distance threshold changed");
    start_session.begin ();
  });

  accuracy_button.notify["selected-item"].connect (() => {
    message ("Accuracy changed");
    portal.location_monitor_stop ();
    accuracy = (Xdp.LocationAccuracy) accuracy_button.selected;
    revealer.reveal_child = false;
    start_session.begin ();
  });

  portal.location_updated.connect (
  (
    latitude,
    longitude,
    altitude,
    accuracy,
    speed,
    heading,
    description,
    timestamp_ms
  ) => {
    message ("Location Updated");
    latitude_label.label = latitude.to_string ();
    longitude_label.label = longitude.to_string ();
    altitude_label.label = altitude.to_string ();
    accuracy_label.label = accuracy.to_string ();
    speed_label.label = speed.to_string ();
    heading_label.label = heading.to_string ();
    description_label.label = description;
    timestamp_label.label = timestamp_ms.to_string ();
  });

  start.clicked.connect (start_session);
  close_button.clicked.connect (() => {
    start.sensitive = true;
    close_button.sensitive = false;
    portal.location_monitor_stop ();
    revealer.reveal_child = false;
    message ("Session Closed");
  });
}

private async void start_session () {
  start.sensitive = false;
  close_button.sensitive = true;

  try {
    bool success = yield portal.location_monitor_start (
      parent,
      distance_threshold,
      time_threshold,
      accuracy,
      NONE,
      null
    );

    if (success) {
      message ("Location Access Granted");
      revealer.reveal_child = true;
    } else {
      message ("Error retrieving location");
    }
  }
  catch (Error e) {
    critical (e.message);
  }
}
