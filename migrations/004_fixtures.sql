-- DETAILS
-- ===========================
-- Children present
-- Gratuitous or excessive search
-- Impact on non-target
-- Involving non-target in raid
-- Intimidation, hostility and/or deception
-- Used Ruse to Gain Ingress
-- Unnecessarily scrutinizing witness ID/docs
-- Use of force/threats

INSERT into api.details (description) values
    ('Children present'),
    ('Gratuitous or excessive search'),
    ('Non-target involved in raid'),
    ('Intimidation, hostility and/or deception'),
    ('Use of ruse or lies to gain ingress'),
    ('Unnecessarily scrutinizing witnesses ID/docs'),
    ('Use of force/threats');


INSERT into api.raid_types (name, description) values
    ('Courthouse Arrest', 'Raids that take place in or outside a court room. Usually during check ins'),
    ('Home Raid',         'Raids that take place at a domicile'),
    ('Shelter Raid',      'Raids that take place at a homeless shelter'),
    ('Street Arrest',     'An arrest that takes place on the street'),
    ('Workplace Arrest',  'A raid or arrest that takes place at a workplace');

INSERT into api.locations (city, state, county) values
    ('Bronx', 'NY', 'Bronx'),
    ('Queens', 'NY', 'Queens'),
    ('Brooklyn', 'NY', 'Kings'),
    ('New York', 'NY', 'New York'),
    ('Staten Island', 'NY', 'Staten Island');


INSERT into api.raids(
        story,
        reference,
        report_citation_reference,
        datetime,
        summary,
        _type,
        status,
        years_in_us,
        non_targets_present,
        location_id
) values (
        'Test Story 001',
        '001',
        'LWD',
        '2017-07-01',
        'This is a messed up thing that happened',
        1,
        'LPR',
        29,
        4,
        1
);
