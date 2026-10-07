import { useState } from "react";

// Topic 1: EVENTS
// An event is something the user does (click, type, submit).
// In React we write events in camelCase, like onClick and onChange.
function Events() {
  const [message, setMessage] = useState("Nothing clicked yet");
  const [name, setName] = useState("");

  // This function runs when the button is clicked
  function handleClick() {
    setMessage("You clicked the button!");
  }

  // We can also pass a value to the function
  function sayHello(person) {
    setMessage("Hello " + person);
  }

  // event.target.value gives us what the user typed
  function handleChange(event) {
    setName(event.target.value);
  }

  return (
    <div>
      <h2>1. Events</h2>

      <p>{message}</p>

      <button onClick={handleClick}>Click Me</button>
      <button onClick={() => sayHello("Student")}>Say Hello</button>

      <p>Type your name:</p>
      <input type="text" value={name} onChange={handleChange} />
      <p>Your name is: {name}</p>
    </div>
  );
}

export default Events;
