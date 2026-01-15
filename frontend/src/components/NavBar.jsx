// NavBar.jsx
import { NavLink, Link } from "react-router-dom";
import "../css/NavBar.css";

function NavBar() {
  return (
    <nav className="nav-bar">
      <div className="nav-logo">
        <Link to="/">Content Base</Link>
      </div>

      <div className="nav-links">
        <NavLink
          to="/" end
          className={({ isActive }) => `nav-link${isActive ? " active" : ""}`}
        >
          Home
        </NavLink>

        <NavLink
          to="/favorites"
          className={({ isActive }) => `nav-link${isActive ? " active" : ""}`}
        >
          Favorites
        </NavLink>
      </div>
    </nav>
  );
}

export default NavBar;
