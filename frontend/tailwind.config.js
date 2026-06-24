/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/app/**/*.{js,jsx,ts,tsx}", "./src/components/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        brand: {
          blue: "#0a53d6",
          dark: "#001a40",
          light: "#f0f4f9",
        }
      }
    },
  },
  plugins: [],
}
