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
