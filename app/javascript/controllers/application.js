import { Application } from "@hotwired/stimulus";
import TomSelect from "@umts/stimulus/tom-select";

const application = Application.start();
application.register("tom-select", TomSelect);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
