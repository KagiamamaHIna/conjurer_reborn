dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")


-- Allow enemies to shoot friends of the same herd genome.
-- Without this the bullets would just go through, with only melee working.
function shot(projectile)
    projectile = EntityObj(projectile)
    local world = EntityObj(GameGetWorldStateEntity())
    local happiness = world.comp.WorldStateComponent[1].attr.global_genome_relations_modifier

    if projectile.comp.ProjectileComponent == nil then
        return
    end
    -- Not every projectile actually has a ProjectileComponent. For example Polyorbs.
    local projComp = projectile.comp_all.ProjectileComponent[1]

    if happiness <= -100 and projComp then
        projComp.set_attrs = {
            friendly_fire = true,

            -- Everyone can self-damage, why not?
            collide_with_shooter_frames = 10,
            explosion_dont_damage_shooter = false,
        }

    end
end
