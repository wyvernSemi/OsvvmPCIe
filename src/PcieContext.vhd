
context PcieContext is

    library osvvm_common ;
    context osvvm_common.OsvvmCommonContext ;

    library osvvm_pcie ;

    use osvvm_pcie.PcieInterfacePkg.all ;
    use osvvm_pcie.PcieOptionsPkg.all ;
    use osvvm_pcie.PcieComponentPkg.all ;

end context PcieContext ;