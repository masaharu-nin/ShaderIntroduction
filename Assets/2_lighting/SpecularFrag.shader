﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sbin/SpecularFrag"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 64)) = 8
    }
    SubShader
    {
        
        pass
        {
            tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            float4 _Diffuse;
            float4 _Specular;
            float _Shininess;
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            struct v2f
            {
                float4 pos: POSITION;
                fixed4 worldNormal: TEXCOORD0;
                float4 wPos: TEXCOORD1;
            };
            v2f vert(a2v a)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(a.vertex);
                o.wPos = mul(unity_ObjectToWorld, a.vertex);
                o.worldNormal = mul(float4(a.normal, 0), unity_WorldToObject);
                return o;
            }
            
            fixed4 frag(v2f f): COLOR
            {
                float4 worldLight = normalize(_WorldSpaceLightPos0);
                float nDot = saturate(dot(normalize(f.worldNormal), worldLight));
                float4 diffuse = _LightColor0 * nDot + UNITY_LIGHTMODEL_AMBIENT;
                //
                diffuse.rgb += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb,
                unity_LightColor[3].rgb, unity_4LightAtten0,
                f.wPos.xyz, f.worldNormal.xyz);
                
                float3 I = -UnityWorldSpaceLightDir(f.wPos);
                float3 V = UnityWorldSpaceViewDir(f.wPos);
                V = normalize(V);
                // float3 R = reflect(I, f.worldNormal);
                float3 R = 2 * dot(worldLight.xyz, f.worldNormal.xyz) * f.worldNormal - worldLight;
                R = normalize(R);
                
                float3 specularScale = pow(saturate(dot(R, V)), _Shininess);
                diffuse.rgb += _Specular * specularScale;
                
                return fixed4(diffuse.rgb, 1);
            }
            ENDCG
            
        }
    }
}