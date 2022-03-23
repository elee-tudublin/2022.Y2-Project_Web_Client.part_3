// Import dependencies
import * as eventData from "./dataAccess/eventData.js";
import * as compData from "./dataAccess/computerData.js";
import * as adminData from "./dataAccess/adminData.js";

/*
  Functions used to update the index page view
*/

// Display event objects in a table element
//
function displayEventList(events) {
  // Use the Array map method to iterate through the array of message documents
  // Each message will be formated as HTML table rows and added to the array
  // see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
  // Finally the output array is inserted as the content into the <tbody id="eventRows"> element.

  // page element where rows will be inserted
  const eventRows = document.getElementById("eventRows");


  const tableRows = events.map((event) => {
    // Return a table row for each events
    // each row added to the tableRows array
    return `<tr>
      <td>${event.type}</td>
      <td>${event.level}</td>
      <td>${moment(new Date(event.timestamp), 'DD MM YYYY hh:mm:ss')}</td>
      <td data-toggle="tooltip" 
        title="computer_id=${event.computer_id}">${event.computers.name}
      </td>
      <td>
        <button data-event_id="${event.id}" 
        class="btn btn-sm btn-outline-danger btn-delete-event">
        <span class="bi bi-trash" data-toggle="tooltip" 
          title="Delete Event">
        </span></button>
      </td>
    </tr>`;
  }); // end events.map

  // Add rows to the table body
  eventRows.innerHTML = tableRows.join('');

    // Add Event listeners
  //
  // 1. Find button all elements with matching class name
  const deleteButtons = document.getElementsByClassName('btn-delete-event');

    // 2. Assign a 'click' event listener to each button
  for (let i = 0; i < deleteButtons.length; i++) {
    deleteButtons[i].addEventListener('click', deleteEvent);
  }

} // End function

// 1. Parse JSON
// 2. Create computer links
// 3. Display in web page
//
function displayComputers(computers) {

  // Use the Array map method to iterate through the array of computers (in json format)
  const compLinks = computers.map((comp) => {

    // return a link button for each computer, setting attribute data-computer_id for the id
    // Also edit and delete buttons
    return `<div class="btn-group">
      <button data-computer_id="${comp.id}" class="list-group-item list-group-item-action computer-button">${comp.name}
      <button data-computer_id="${comp.id}" 
          class="btn btn-sm btn-outline-primary btn-update-computer" 
          data-bs-toggle="modal" data-bs-target="#ComputerFormDialog" >
          <span class="bi bi-pencil-square" 
          data-toggle="tooltip" title="Edit Computer">
          </span>
      </button>
      <button data-computer_id="${comp.id}" 
          class="btn btn-sm btn-outline-danger btn-delete-computer">
          <span class="bi bi-trash" data-toggle="tooltip" 
          title="Delete Computer">
          </span>
      </button>
    </div>`;

  }); // end computers.map

  // Add a link for 'all computers' to start of the list
  // first check compLinks is an array
  if (Array.isArray(compLinks)) {
    // Then use unshift to move all elements up one and insert a new element at the start
    // This button has computer_id=0
    compLinks.unshift(`<button data-computer_id="0" 
                        class="list-group-item list-group-item-action computer-button">
                        All Computers
                      </button>`);
  }

  // Set the innerHTML of the eventRows root element = rows
  // join('') converts the rows array to a string, replacing the ',' delimiter with '' (blank)
  document.getElementById('computerList').innerHTML = compLinks.join("");

  // Add Event listeners to handle clicks
  // When clicked, the computer links will filter events - displaying  events for that computer
  //
  // 1. Find button all elements with matching the class name used to identify computer buttons
  const compButtons = document.getElementsByClassName('computer-button');
  const deleteButtons = document.getElementsByClassName('btn-delete-computer');
  const updateButtons = document.getElementsByClassName('btn-update-computer');

  // 2. Assign a 'click' event listener to each button
  // When clicked the filterComputer() function will be called.
  for (let i = 0; i < compButtons.length; i++) {
    compButtons[i].addEventListener('click', filterComputers);
  };

  // Set up delete buutons
  // setup edit buttons
  for (let i = 0; i < deleteButtons.length; i++) {
    deleteButtons[i].addEventListener('click', deleteComputer);
    updateButtons[i].addEventListener('click', prepareUpdate);
  }
} // end function


// Show events for the selected computer
//
async function filterComputers() {

    // Get id of cat link (from the data attribute)
    // https://developer.mozilla.org/en-US/docs/Learn/HTML/Howto/Use_data_attributes
    const compId = Number(this.dataset.computer_id);

    // validation - if 0 or NaN reload everything
    if (isNaN(compId) || compId == 0) {
      loadAndDisplayData();
    
    // Otherwise get events for this computer
    } else {

      // Get events
      const events = await eventData.getEventByCompId(compId);

      // If events returned then display them
      if (Array.isArray(events)) {
        displayEventList(events);
      }
    }
}

//
// Setup computer form with defaults
//
function computerFormSetup(event, formTitle = 'Add a new Computer') {
  // reset the form and change the title
  document.getElementById('computerForm').reset();
  document.getElementById('computerFormTitle').innerText = formTitle;

  // form reset doesn't work for hidden inputs!!
  // do this to rreset previous id if set
  document.getElementById("id").value = 0;
} // end function

// Fill the form when an edit button is clicked
async function prepareUpdate() {

  // Get the computer using the computer_id value of the clicked butoon
  const comp = await compData.getComputerById(this.dataset.computer_id);

  // If found - fill the form
  if (comp) {
    //Set form input values
    computerFormSetup(0, `Update Computer ID: ${comp.id}`);
    computerForm.id.value = comp.id;
    computerForm.name.value = comp.name;
    computerForm.description.value = comp.description;
    computerForm.location.value = comp.location;
  }

} // End function

// Get values from computer form
// return as an object
function getComputerFormData() {
  // use form and input NAMES to access values
  // Note: These should be validated!!
  return {
    id: Number(computerForm.id.value),
    name: computerForm.name.value,
    description: computerForm.description.value,
    location: computerForm.location.value
  };

} // End function

//
// Called when computer form is submitted
//
async function addOrUpdateComputer() {
  const comp = getComputerFormData();
  let result;

  // New computer will have id set to 0
  if (comp.id === 0) {
    // add new
    result = await adminData.addComputer(comp);
  } else {
    // update existing
    result = await adminData.updateComputer(comp);
  }
  return result;
} // End function


// Delete event by id using an HTTP DELETE request
async function deleteComputer() {
  // Confirm delete
  if (confirm(`Are you sure you want to delete computer id = ${this.dataset.computer_id} ?`)) {
    // call the delete function (from adminData.js)
    // passing the data-computer_id value of the clicked button
    const result = await adminData.deleteComputer(this.dataset.computer_id);
  }
} // End function

// Delete event by id
async function deleteEvent() {
  // Confirm delete
  if (confirm(`Are you sure you want to delete event id = ${this.dataset.event_id} ?`)) {
    // call the delete function (from adminData.js)
    // passing the data-computer_id value of the clicked button
    const result = await adminData.deleteEventById(this.dataset.event_id);
  } 
} // End Function

// Get JSON array of events
// Then pass that data for display
//
async function loadAndDisplayData() {
  
  // Load all computers and display
  const computers = await compData.getAllComputers();
  console.log("computers:", computers);
  displayComputers(computers);
  
  // load all events and display
  const events = await eventData.getAllEvents();
  console.log("events:", events);
  displayEventList(events);
}

// Add event listener to the Add event Button
document.getElementById('AddComputerButton').addEventListener('click', computerFormSetup);

// Add event listner to form submit/ save button
// Second param is an inline function - used as the event object is required
document.getElementById('formSubmit').addEventListener('click',addOrUpdateComputer);


// Initial data load
loadAndDisplayData();

// Subscribe to changes (e.g. new events)
// This will refresh display when new events are added
const eventsSub = eventData.Supabase
  .from('*')
  .on('*', loadAndDisplayData)
  .subscribe();
