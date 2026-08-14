function SummaryCard({ title, value, color }) {
  return (
    <div
      style={{
        background: color,
        color: "white",
        padding: "18px",
        borderRadius: "15px",
        flex: 1,
      }}
    >
      <h4>{title}</h4>
      <h2>{value}</h2>
    </div>
  );
}

export default SummaryCard;