function QuickAction({ title }) {
  return (
    <button
      style={{
        padding: "18px",
        borderRadius: "15px",
        border: "none",
        background: "#f5f7fb",
        fontWeight: "bold",
        cursor: "pointer",
      }}
    >
      {title}
    </button>
  );
}

export default QuickAction;