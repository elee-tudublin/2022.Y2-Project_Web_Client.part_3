/*
  Admin db access
*/

// Get a db connection by importing supabase.js which sets it up
import { Supabase } from './supabase.js';

// Insert a new computer
async function addComputer(comp) {
    console.log('insert computer id: ', comp.id);
    const result = await Supabase
    .from('computers')
    .insert([
        { name: comp.name, 
        description: comp.description, 
        location:  comp.location
        },
    ]);

    // return the result data
    return result.data;
} // end function

// update an existing computer
async function updateComputer(comp) {
    console.log('to update: ', comp.id);
    const result= await Supabase
    .from('computers')
    .update([
        { name: comp.name, 
        description: comp.description, 
        location:  comp.location
        },
    ])
    // update where id matches comp.id
    .eq('id', comp.id);

    // return the result data
    return result.data;
}

// delete a computer
async function deleteComputer(id) {

    // before deleting computer, delete its events
    const del_Events = deleteComputerEvents(id);
    
    const result= await Supabase
    .from('computers')
    .delete()
    .eq('id', id);

    // return the result data
    return result.data;
}

// delete a computers events
async function deleteComputerEvents(comp_id) {
    
    const result= await Supabase
    .from('events')
    .delete()
    .eq('computer_id', comp_id);

    // return the result data
    return result.data;
}

// delete an event
async function deleteEventById(id) {
    
    const result= await Supabase
    .from('events')
    .delete()
    .eq('id', id);

    // return the result data
    return result.data;
}

// Export functions for import elsewhere
export {
    addComputer,
    updateComputer,
    deleteComputer,
    deleteEventById,
    deleteComputerEvents
  };