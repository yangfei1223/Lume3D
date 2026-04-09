{
    "compatibility_info": {
        "version": "22.00",
        "type": "shader"
    },
    "category": "3D/Material",
    "materialMetadata" : [
        {
            "name" : "MaterialComponent",
            "properties" : {
                "textures" : [
                    { "name" : "baseColor", "displayName" : "Base Color" },
                    { "name" : "normal", "displayName" : "Normal Map" },
                    { "name" : "material", "displayName" : "Material" },
                    { "name" : "emissive", "displayName" : "Emissive" },
                    { "name" : "ambientOcclusion", "displayName" : "Ambient Occlusion" },
                    { "name" : "clearcoat", "displayName" : "Clearcoat" },
                    { "name" : "clearcoatRoughness", "displayName" : "Clearcoat Roughness" },
                    { "name" : "clearcoatNormal", "displayName" : "Clearcoat Normal" },
                    { "name" : "sheen", "displayName" : "Sheen" },
                    { "name" : "transmission", "displayName" : "Transmission" },
                    { "name" : "specular", "displayName" : "Specular" }
                ]
            }
        }
    ],
    "shaders": [
        {
            "displayName": "Deferred with UV Output",
            "variantName": "OPAQUE_DF_UV",
            "renderSlot": "CORE3D_RS_DM_DF_OPAQUE_UV",
            "renderSlotDefaultShader": true,
            "vert": "3dshaders://shader/core3d_dm_fw.vert.spv",
            "frag": "3dshaders://shader/core3d_dm_df_uv.frag.spv",
            "vertexInputDeclaration": "3dvertexinputdeclarations://core3d_dm_fw.shadervid",
            "pipelineLayout": "3dpipelinelayouts://core3d_dm_fw.shaderpl",
            "state": {
                "rasterizationState": {
                    "enableDepthClamp": false,
                    "enableDepthBias": false,
                    "enableRasterizerDiscard": false,
                    "polygonMode": "fill",
                    "cullModeFlags": "back",
                    "frontFace": "counter_clockwise"
                },
                "depthStencilState": {
                    "enableDepthTest": true,
                    "enableDepthWrite": true,
                    "enableDepthBoundsTest": false,
                    "enableStencilTest": false,
                    "depthCompareOp": "less_or_equal"
                },
                "colorBlendState": {
                    "colorAttachments": [
                        {
                            "colorWriteMask": "r_bit|g_bit|b_bit|a_bit"
                        },
                        {
                            "colorWriteMask": "r_bit|g_bit|b_bit|a_bit"
                        },
                        {
                            "colorWriteMask": "r_bit|g_bit|b_bit|a_bit"
                        },
                        {
                            "colorWriteMask": "r_bit|g_bit|b_bit|a_bit"
                        },
                        {
                            "colorWriteMask": "r_bit|g_bit|b_bit|a_bit"
                        }
                    ]
                }
            }
        }
    ]
}
