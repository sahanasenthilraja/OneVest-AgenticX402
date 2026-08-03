import "../styles/Login.css";

function Login() {
  return (
    <div className="login-container">
      <div className="login-card">
        <h1>OneVest</h1>

        <p className="subtitle">
          Smart Investing Starts Here
        </p>

        <input
          type="text"
          placeholder="Enter Mobile Number"
        />

        <button>Continue</button>

        <p className="or">OR</p>

        <button className="google">
          Continue with Google
        </button>
      </div>
    </div>
  );
}

export default Login;