import { useEffect, useState } from "react";
import axios from "axios";

// ❗ NO trailing slash here
const API = "https://d3tzh0t1qyifvu.cloudfront.net/api";

function App() {
  const [name, setName] = useState("");
  const [users, setUsers] = useState([]);

  const fetchUsers = async () => {
    const res = await axios.get(`${API}/users`);
    setUsers(res.data);
  };

  const addUser = async () => {
    await axios.post(`${API}/users`, { name });
    setName("");
    fetchUsers();
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h1>Web based Cloud Applications 🚀</h1>

      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter name"
      />
      <button onClick={addUser}>Add</button>

      <ul>
        {users.map((u) => (
          <li key={u.id}>{u.name}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;