/* global ethers */
// DApp de Registro de Certificados — ethers.js v6 + MetaMask.
// Lee la dirección y el ABI del contrato desde deployment.json (lo genera scripts/deploy.js).

let provider;
let signer;
let contrato;
let deployment;

const $ = (id) => document.getElementById(id);

async function cargarDeployment() {
  const resp = await fetch("./deployment.json");
  if (!resp.ok) {
    throw new Error(
      "No se encontró deployment.json. Ejecuta primero: npm run deploy:local"
    );
  }
  return resp.json();
}

async function conectar() {
  if (typeof window.ethereum === "undefined") {
    alert("Instala MetaMask para usar esta DApp.");
    return;
  }
  try {
    deployment = await cargarDeployment();

    provider = new ethers.BrowserProvider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = await provider.getSigner();
    const direccion = await signer.getAddress();

    contrato = new ethers.Contract(deployment.address, deployment.abi, signer);

    $("estado-conexion").textContent = "Conectado";
    $("estado-conexion").className = "badge conectado";
    $("cuenta").textContent = `Cuenta: ${direccion}`;
    $("info-contrato").textContent =
      `Contrato: ${deployment.address} · red: ${deployment.network} (chainId ${deployment.chainId})`;
  } catch (err) {
    console.error(err);
    alert(`Error al conectar: ${err.message}`);
  }
}

async function emitir() {
  const nombre = $("emitir-nombre").value.trim();
  const curso = $("emitir-curso").value.trim();
  const salida = $("emitir-resultado");
  if (!contrato) return alert("Conecta MetaMask primero.");
  if (!nombre || !curso) return alert("Completa nombre y curso.");

  try {
    salida.textContent = "⏳ Enviando transacción...";
    const tx = await contrato.emitirCertificado(nombre, curso);
    const recibo = await tx.wait();
    // El primer argumento del evento CertificadoEmitido es el hash.
    const evento = recibo.logs
      .map((l) => {
        try {
          return contrato.interface.parseLog(l);
        } catch {
          return null;
        }
      })
      .find((e) => e && e.name === "CertificadoEmitido");
    const hash = evento.args[0];
    salida.innerHTML = `✅ Certificado emitido.<br/>Hash: <code>${hash}</code>`;
  } catch (err) {
    salida.textContent = `❌ ${parseError(err)}`;
  }
}

async function verificar() {
  const hash = $("verificar-hash").value.trim();
  const salida = $("verificar-resultado");
  if (!contrato) return alert("Conecta MetaMask primero.");
  if (!hash) return alert("Pega el hash del certificado.");

  try {
    const [existe, valido, nombre, curso, emisor, fecha] =
      await contrato.verificarCertificado(hash);
    if (!existe) {
      salida.textContent = "⚠️ Ese certificado no existe.";
      return;
    }
    const fechaTxt = new Date(Number(fecha) * 1000).toLocaleString();
    salida.innerHTML = `
      ${valido ? "✅ <b>VÁLIDO</b>" : "❌ <b>REVOCADO</b>"}<br/>
      Estudiante: ${nombre}<br/>
      Curso: ${curso}<br/>
      Emisor: <code>${emisor}</code><br/>
      Emitido: ${fechaTxt}`;
  } catch (err) {
    salida.textContent = `❌ ${parseError(err)}`;
  }
}

async function revocar() {
  const hash = $("revocar-hash").value.trim();
  const salida = $("revocar-resultado");
  if (!contrato) return alert("Conecta MetaMask primero.");
  if (!hash) return alert("Pega el hash del certificado.");

  try {
    salida.textContent = "⏳ Enviando transacción...";
    const tx = await contrato.revocarCertificado(hash);
    await tx.wait();
    salida.textContent = "✅ Certificado revocado.";
  } catch (err) {
    salida.textContent = `❌ ${parseError(err)}`;
  }
}

// Traduce los errores personalizados del contrato a mensajes legibles.
function parseError(err) {
  const data = err?.info?.error?.message || err?.shortMessage || err?.message || "Error";
  if (data.includes("NoEsEmisorAutorizado")) return "No estás autorizado como emisor.";
  if (data.includes("NoEsPropietario")) return "Solo el propietario puede hacer esto.";
  if (data.includes("CertificadoNoExiste")) return "Ese certificado no existe.";
  if (data.includes("CertificadoYaRevocado")) return "El certificado ya estaba revocado.";
  if (data.includes("DatosVacios")) return "Nombre y curso no pueden estar vacíos.";
  return data;
}

$("btn-conectar").addEventListener("click", conectar);
$("btn-emitir").addEventListener("click", emitir);
$("btn-verificar").addEventListener("click", verificar);
$("btn-revocar").addEventListener("click", revocar);

// Si el usuario cambia de cuenta o red, recargamos para reconectar limpio.
if (window.ethereum) {
  window.ethereum.on("accountsChanged", () => window.location.reload());
  window.ethereum.on("chainChanged", () => window.location.reload());
}
