Noise = {}
Noise.__index = Noise

function Noise:create()
    local noise = {}
    setmetatable(noise, Noise)

    local permutation = { 151, 160, 137, 91, 90, 15,
        131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
        190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
        88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
        77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
        102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
        135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
        5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
        223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
        129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
        251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
        49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
        138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180 }
    noise.p = {}

    for i = 1, 512 do
        noise.p[i] = permutation[i % 256 + 1]
    end

    return noise
end

function Noise:perlin(x, y, z)
    local xBitwised = math.floor(x) and 255
    local yBitwised = math.floor(y) and 255
    local zBitwised = math.floor(z) and 255

    local xf = x - math.floor(x)
    local yf = y - math.floor(y)
    local zf = z - math.floor(z)

    local u = self:fade(xf)
    local v = self:fade(yf)
    local w = self:fade(zf)

    local A = self.p[xBitwised] + yBitwised
    local AA = self.p[A] + zBitwised
    local AB = self.p[A + 1] + zBitwised
    local B = self.p[xBitwised + 1] + yBitwised
    local BA = self.p[B] + zBitwised
    local BB = self.p[B + 1] + zBitwised

    local a = self:lerp(v,
        self:lerp(u, self:grad(self.p[AA], x, y, z), self:grad(self.p[BA], x - 1, y, z)),
        self:lerp(u, self:grad(self.p[AB], x, y - 1, z), self:grad(self.p[BB], x - 1, y - 1, z))
    )
    local b = self:lerp(v,
        self:lerp(u, self:grad(self.p[AA + 1], x, y, z - 1), self:grad(self.p[BA + 1], x - 1, y, z - 1)),
        self:lerp(u, self:grad(self.p[AB + 1], x, y - 1, z - 1), self:grad(self.p[BB + 1], x - 1, y - 1, z - 1))
    )

    return self:lerp(w, a, b)
end

function Noise:lerp(t, a, b)
    return a + t * (b - a)
end

function Noise:fade(t)
    return math.pow(t, 3) * (t * (t * 6 - 15) + 10);
end

function Noise:grad(hash, x, y, z)
    local bitProduct = hash and 0xF

    if bitProduct == 0x0 then
        return x + y
    elseif bitProduct == 0x1 then
        return -x + y
    elseif bitProduct == 0x2 then
        return x - y
    elseif bitProduct == 0x3 then
        return -x - y
    elseif bitProduct == 0x4 then
        return x + z
    elseif bitProduct == 0x5 then
        return -x + z
    elseif bitProduct == 0x6 then
        return x - z
    elseif bitProduct == 0x7 then
        return -x - z
    elseif bitProduct == 0x8 then
        return y + z
    elseif bitProduct == 0x9 then
        return -y + z
    elseif bitProduct == 0xA then
        return y - z
    elseif bitProduct == 0xB then
        return -y - z
    elseif bitProduct == 0xC then
        return y + x
    elseif bitProduct == 0xD then
        return -y + z
    elseif bitProduct == 0xE then
        return y - x
    elseif bitProduct == 0xF then
        return -y - z
    else
        return 0
    end
end
