import { useState } from "react";

// Topic 3: LISTS
// We use the map() function to turn an array into a list of elements.
// Every item needs a unique "key" so React can track it.
function Lists() {
  const [subjects, setSubjects] = useState([
    { id: 1, name: "Database" },
    { id: 2, name: "Web Development" },
    { id: 3, name: "Data Structures" },
  ]);
  const [newSubject, setNewSubject] = useState("");

  function addSubject() {
    // do not add empty text
    if (newSubject === "") {
      return;
    }
    const item = { id: Date.now(), name: newSubject };
    setSubjects([...subjects, item]);
    setNewSubject("");
  }

  function removeSubject(id) {
    // keep every subject except the one with this id
    setSubjects(subjects.filter((subject) => subject.id !== id));
  }

  return (
    <div>
      <h2>3. Lists</h2>

      <p>My Subjects:</p>
      <ul>
        {subjects.map((subject) => (
          <li key={subject.id}>
            {subject.name}{" "}
            <button onClick={() => removeSubject(subject.id)}>Remove</button>
          </li>
        ))}
      </ul>

      {subjects.length === 0 && <p>No subjects left.</p>}

      <input
        type="text"
        value={newSubject}
        onChange={(e) => setNewSubject(e.target.value)}
      />
      <button onClick={addSubject}>Add Subject</button>
    </div>
  );
}

export default Lists;
