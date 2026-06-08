const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RegistroCertificados", function () {
  let contrato;
  let propietario, emisor, otro, estudiante;

  beforeEach(async function () {
    [propietario, emisor, otro, estudiante] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("RegistroCertificados");
    contrato = await Factory.deploy();
    await contrato.waitForDeployment();
  });

  describe("Despliegue", function () {
    it("1. asigna como propietario a quien despliega", async function () {
      expect(await contrato.propietario()).to.equal(propietario.address);
    });

    it("2. autoriza al propietario como emisor por defecto", async function () {
      expect(await contrato.emisorAutorizado(propietario.address)).to.equal(true);
    });
  });

  describe("Gestión de emisores", function () {
    it("3. el propietario puede autorizar un emisor", async function () {
      await expect(contrato.autorizarEmisor(emisor.address))
        .to.emit(contrato, "EmisorAutorizado")
        .withArgs(emisor.address, propietario.address);
      expect(await contrato.emisorAutorizado(emisor.address)).to.equal(true);
    });

    it("4. el propietario puede revocar un emisor", async function () {
      await contrato.autorizarEmisor(emisor.address);
      await expect(contrato.revocarEmisor(emisor.address))
        .to.emit(contrato, "EmisorRevocado")
        .withArgs(emisor.address, propietario.address);
      expect(await contrato.emisorAutorizado(emisor.address)).to.equal(false);
    });

    it("5. un no-propietario NO puede autorizar emisores", async function () {
      await expect(
        contrato.connect(otro).autorizarEmisor(emisor.address)
      ).to.be.revertedWithCustomError(contrato, "NoEsPropietario");
    });

    it("6. rechaza autorizar la dirección cero", async function () {
      await expect(
        contrato.autorizarEmisor(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(contrato, "DireccionInvalida");
    });
  });

  describe("Emisión de certificados", function () {
    it("7. un emisor autorizado puede emitir un certificado", async function () {
      await expect(contrato.emitirCertificado("Ada Lovelace", "Blockchain 101")).to.emit(
        contrato,
        "CertificadoEmitido"
      );
    });

    it("8. un no-emisor NO puede emitir certificados", async function () {
      await expect(
        contrato.connect(otro).emitirCertificado("Ada Lovelace", "Blockchain 101")
      ).to.be.revertedWithCustomError(contrato, "NoEsEmisorAutorizado");
    });

    it("9. rechaza datos vacíos", async function () {
      await expect(
        contrato.emitirCertificado("", "Blockchain 101")
      ).to.be.revertedWithCustomError(contrato, "DatosVacios");
    });

    it("10. un certificado emitido se verifica como válido", async function () {
      const tx = await contrato.emitirCertificado("Ada Lovelace", "Blockchain 101");
      const recibo = await tx.wait();
      const evento = recibo.logs.find((l) => l.fragment?.name === "CertificadoEmitido");
      const hash = evento.args[0];

      const [existe, valido, nombre, curso] = await contrato.verificarCertificado(hash);
      expect(existe).to.equal(true);
      expect(valido).to.equal(true);
      expect(nombre).to.equal("Ada Lovelace");
      expect(curso).to.equal("Blockchain 101");
    });
  });

  describe("Revocación de certificados", function () {
    let hash;

    beforeEach(async function () {
      const tx = await contrato.emitirCertificado("Grace Hopper", "DevSecOps");
      const recibo = await tx.wait();
      const evento = recibo.logs.find((l) => l.fragment?.name === "CertificadoEmitido");
      hash = evento.args[0];
    });

    it("11. un certificado revocado deja de ser válido pero sigue existiendo", async function () {
      await expect(contrato.revocarCertificado(hash))
        .to.emit(contrato, "CertificadoRevocado")
        .withArgs(hash, propietario.address);

      const [existe, valido] = await contrato.verificarCertificado(hash);
      expect(existe).to.equal(true);
      expect(valido).to.equal(false);
    });

    it("12. no se puede revocar un certificado inexistente", async function () {
      const hashFalso = ethers.keccak256(ethers.toUtf8Bytes("no-existe"));
      await expect(
        contrato.revocarCertificado(hashFalso)
      ).to.be.revertedWithCustomError(contrato, "CertificadoNoExiste");
    });
  });
});
