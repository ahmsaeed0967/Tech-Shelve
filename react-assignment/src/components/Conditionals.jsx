import { useState } from "react";

// Topic 2: CONDITIONALS
// Conditional rendering means showing different things
// depending on a condition (true or false).
function Conditionals() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [marks, setMarks] = useState(0);

  // Way 1: if statement (used outside the return)
  function showGreeting() {
    if (isLoggedIn) {
      return <p>Welcome back, student!</p>;
    } else {
      return <p>Please log in.</p>;
    }
  }

  return (
    <div>
      <h2>2. Conditionals</h2>

      {/* Way 1: if / else inside a function */}
      {showGreeting()}

      {/* Way 2: ternary operator  (condition ? yes : no) */}
      <button onClick={() => setIsLoggedIn(!isLoggedIn)}>
        {isLoggedIn ? "Log Out" : "Log In"}
      </button>

      {/* Way 3: && operator (shows only when condition is true) */}
      {isLoggedIn && <p>You can now see your marks below.</p>}

      {isLoggedIn && (
        <div>
          <p>Marks: {marks}</p>
          <button onClick={() => setMarks(marks + 10)}>Add 10 Marks</button>
          <button onClick={() => setMarks(0)}>Reset</button>

          {marks >= 50 ? <p>Result: Pass</p> : <p>Result: Fail</p>}
        </div>
      )}
    </div>
  );
}

export default Conditionals;
